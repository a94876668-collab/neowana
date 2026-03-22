const express = require('express');
const http = require('http');
const { WebSocketServer } = require('ws');

// 금지어 목록 (민감 단어 포함 시 메시지 차단)
const FORBIDDEN_KEYWORDS = [
  '마약', '필로폰', '얼음', '대마', '코카인', '헤로인', '각성제',
  '밀수', '밀입국', '불법촬영', '몰카', '성매매', '성매수',
  '보이스피싱', '사기', '해킹', '마약거래', '유통'
];

function containsForbiddenKeyword(text) {
  if (!text || typeof text !== 'string') return false;
  const lower = text.toLowerCase();
  return FORBIDDEN_KEYWORDS.some(kw => lower.includes(kw.toLowerCase()));
}

const MAINTENANCE = process.env.MAINTENANCE === 'true';

const app = express();
const server = http.createServer(app);

const wss = new WebSocketServer({ server, path: '/ws' });

app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  next();
});

app.get('/', (req, res) => {
  if (MAINTENANCE) return res.send('점검 중입니다. 내일까지 이용 불가합니다.');
  res.send('너와나 서버 실행 중');
});

let clientId = 0;
const clients = new Map();
let waitingQueue = [];

wss.on('connection', (ws, req) => {
  if (MAINTENANCE) {
    ws.send(JSON.stringify({ type: 'error', message: '점검 중입니다. 내일까지 이용 불가합니다.' }));
    ws.close();
    return;
  }

  const id = `user_${++clientId}_${Date.now()}`;
  clients.set(id, { ws, roomId: null });
  console.log('[연결]', id, '- 대기열:', waitingQueue.length);

  // 연결 유지 (일부 환경에서 idle 연결 끊김 방지)
  const pingInterval = setInterval(() => {
    if (ws.readyState === 1) ws.ping();
  }, 30000);
  ws.once('close', () => clearInterval(pingInterval));

  ws.on('message', (data) => {
    try {
      const msg = JSON.parse(data.toString());
      handleMessage(id, msg);
    } catch (e) {
      console.error('파싱 오류:', e);
    }
  });

  ws.on('close', (code, reason) => {
    const info = clients.get(id);
    console.log('[연결 해제]', id, '- 사유:', code, reason?.toString());
    if (info?.roomId) {
      const roomClients = [...clients.entries()].filter(
        ([_, v]) => v.roomId === info.roomId
      );
      roomClients.forEach(([otherId, otherInfo]) => {
        if (otherId !== id && otherInfo.ws.readyState === 1) {
          otherInfo.ws.send(JSON.stringify({ type: 'partner_left', message: '상대방이 나갔습니다.' }));
        }
        otherInfo.roomId = null;
      });
    }
    waitingQueue = waitingQueue.filter(x => x !== id);
    clients.delete(id);
  });

  ws.on('error', (err) => {
    console.log('[오류]', id, err.message);
  });
});

function handleMessage(id, msg) {
  const info = clients.get(id);
  if (!info) return;

  if (msg.type === 'find_match') {
    if (info.roomId) return;
    if (waitingQueue.includes(id)) return;

    waitingQueue.push(id);

    if (waitingQueue.length >= 2) {
      const id1 = waitingQueue.shift();
      const id2 = waitingQueue.shift();

      // 같은 연결이 중복으로 매칭되는 것 방지
      if (id1 === id2) {
        waitingQueue.unshift(id1);
        console.log('[거부] 같은 연결 중복 매칭 시도');
        return;
      }

      const roomId = `room_${Date.now()}`;
      const c1 = clients.get(id1);
      const c2 = clients.get(id2);

      if (!c1 || !c2) {
        if (c1) waitingQueue.unshift(id1);
        if (c2) waitingQueue.unshift(id2);
        return;
      }
      if (c1.ws.readyState !== 1 || c2.ws.readyState !== 1) {
        waitingQueue.unshift(id1);
        waitingQueue.unshift(id2);
        console.log('[거부] 한쪽 연결 불안정');
        return;
      }

      c1.roomId = roomId;
      c2.roomId = roomId;

      // 매칭 알림 전송 전 약간 대기 (연결 안정화)
      setTimeout(() => {
        if (c1.ws.readyState === 1) c1.ws.send(JSON.stringify({ type: 'matched' }));
        if (c2.ws.readyState === 1) c2.ws.send(JSON.stringify({ type: 'matched' }));
        console.log('[매칭 완료]', id1, '<->', id2);
      }, 100);
    } else {
      info.ws.send(JSON.stringify({ type: 'waiting' }));
    }
  } else if (msg.type === 'cancel_match') {
    waitingQueue = waitingQueue.filter(x => x !== id);
    info.ws.send(JSON.stringify({ type: 'status', message: '취소됨' }));
  } else if (msg.type === 'report' && info.roomId) {
    const roomClients = [...clients.entries()].filter(
      ([_, v]) => v.roomId === info.roomId
    );
    roomClients.forEach(([otherId]) => {
      if (otherId !== id) {
        console.log('[신고]', id, '→', otherId);
      }
    });
  } else if (msg.type === 'typing' && info.roomId) {
    const roomClients = [...clients.entries()].filter(
      ([_, v]) => v.roomId === info.roomId
    );
    roomClients.forEach(([otherId, otherInfo]) => {
      if (otherId !== id && otherInfo.ws.readyState === 1) {
        otherInfo.ws.send(JSON.stringify({ type: 'typing' }));
      }
    });
  } else if (msg.type === 'stopped_typing' && info.roomId) {
    const roomClients = [...clients.entries()].filter(
      ([_, v]) => v.roomId === info.roomId
    );
    roomClients.forEach(([otherId, otherInfo]) => {
      if (otherId !== id && otherInfo.ws.readyState === 1) {
        otherInfo.ws.send(JSON.stringify({ type: 'stopped_typing' }));
      }
    });
  } else if (msg.type === 'chat_message' && info.roomId) {
    const message = msg.message || '';
    if (containsForbiddenKeyword(message)) {
      try {
        info.ws.send(JSON.stringify({ type: 'message_blocked' }));
        console.log('[차단]', id, '- 금지어 포함 메시지');
      } catch (e) {
        console.error('[차단 알림 실패]', e.message);
      }
      return;
    }
    const roomClients = [...clients.entries()].filter(
      ([_, v]) => v.roomId === info.roomId
    );
    const payload = JSON.stringify({
      type: 'chat_message',
      userId: id,
      message
    });
    roomClients.forEach(([otherId, otherInfo]) => {
      if (otherId !== id && otherInfo.ws.readyState === 1) {
        try {
          otherInfo.ws.send(payload);
          console.log('[채팅]', id, '→', otherId);
        } catch (e) {
          console.error('[채팅 전송 실패]', otherId, e.message);
        }
      }
    });
  }
}

const PORT = 3000;
server.listen(PORT, () => {
  console.log(`\n너와나 서버: http://localhost:${PORT}`);
  console.log('WebSocket: ws://localhost:${PORT}/ws\n');
});
