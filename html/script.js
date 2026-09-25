const panel = document.getElementById('panel');
const totalOnlineEl = document.getElementById('totalOnline');
const areaCountEl = document.getElementById('areaCount');
const listEl = document.getElementById('playerList');
const tabOnline = document.getElementById('tabOnline');
const tabDisconnected = document.getElementById('tabDisconnected');

const cfg = {
  showPing: false,
  text: {
    active: 'Active', id: 'ID',
    emptyOnline: 'No players online',
    emptyDisconnected: 'No disconnected players yet'
  }
};

function hexToRgb(hex) {
  const m = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex || '');
  return m ? `${parseInt(m[1], 16)}, ${parseInt(m[2], 16)}, ${parseInt(m[3], 16)}` : null;
}

function applyConfig(d) {
  const root = document.documentElement.style;
  const ui = d.ui || {};
  const t = d.text || {};

  if (ui.accentColor) { root.setProperty('--cyan', ui.accentColor); const r = hexToRgb(ui.accentColor); if (r) root.setProperty('--cyan-rgb', r); }
  if (ui.activeColor) root.setProperty('--active', ui.activeColor);
  if (ui.idColor) root.setProperty('--green', ui.idColor);
  if (ui.disconnectedColor) { root.setProperty('--red', ui.disconnectedColor); const r = hexToRgb(ui.disconnectedColor); if (r) root.setProperty('--red-rgb', r); }
  if (ui.width) root.setProperty('--panel-width', ui.width + 'px');
  panel.classList.toggle('left', ui.position === 'left');

  const set = (id, v) => { if (v !== undefined) document.getElementById(id).textContent = v; };
  set('txtTitle', t.title);
  set('txtSubtitle', t.subtitle);
  set('txtTotal', t.totalLabel);
  set('txtArea', t.areaLabel);
  set('txtTabOnline', t.tabOnline);
  set('txtTabDisc', t.tabDisconnected);
  if (d.keys) { set('keyOnline', d.keys.online); set('keyDisc', d.keys.disconnected); }

  Object.assign(cfg.text, t);
  cfg.showPing = !!d.showPing;
}

const personIcon = `<svg viewBox="0 0 24 24"><path d="M12 12c2.7 0 4.9-2.2 4.9-4.9S14.7 2.2 12 2.2 7.1 4.4 7.1 7.1 9.3 12 12 12zm0 2.5c-3.3 0-9.8 1.6-9.8 4.9V22h19.6v-2.6c0-3.3-6.5-4.9-9.8-4.9z"/></svg>`;

function setActiveTab(tab) {
  tabOnline.classList.toggle('active', tab === 'online');
  tabDisconnected.classList.toggle('active', tab === 'disconnected');
}

function renderOnline(players) {
  if (!players || players.length === 0) {
    listEl.innerHTML = `<div class="empty-state">${escapeHtml(cfg.text.emptyOnline)}</div>`;
    return;
  }
  listEl.innerHTML = players.map(p => `
    <div class="player-row">
      <div class="avatar">${personIcon}</div>
      <div class="player-info">
        <span class="player-name">${escapeHtml(p.name)}</span>
        <span class="player-slot">${escapeHtml(cfg.text.id)}: ${p.slot}</span>
      </div>
      <span class="player-ping">${cfg.showPing ? p.ping + 'ms' : escapeHtml(cfg.text.active)}</span>
    </div>
  `).join('');
}

function renderDisconnected(players) {
  if (!players || players.length === 0) {
    listEl.innerHTML = `<div class="empty-state">${escapeHtml(cfg.text.emptyDisconnected)}</div>`;
    return;
  }
  listEl.innerHTML = players.map(p => `
    <div class="player-row disconnected">
      <div class="avatar">${personIcon}</div>
      <div class="player-info">
        <span class="player-name">${escapeHtml(p.name)}</span>
        <span class="player-slot">${escapeHtml(cfg.text.id)}: ${p.slot} • ${escapeHtml(p.time || '')}</span>
      </div>
      <span class="player-ping">${escapeHtml(p.reason || '')}</span>
    </div>
  `).join('');
}

function escapeHtml(str) {
  const div = document.createElement('div');
  div.textContent = str ?? '';
  return div.innerHTML;
}

window.addEventListener('message', (event) => {
  const data = event.data;

  switch (data.action) {
    case 'config':
      applyConfig(data);
      break;

    case 'toggle':
      panel.classList.toggle('hidden', !data.open);
      break;

    case 'setTab':
      setActiveTab(data.tab);
      break;

    case 'updateOnline':
      totalOnlineEl.textContent = data.total;
      renderOnline(data.players);
      break;

    case 'updateArea':
      areaCountEl.textContent = data.count;
      break;

    case 'updateDisconnected':
      renderDisconnected(data.players);
      break;
  }
});

tabOnline.addEventListener('click', () => {
  setActiveTab('online');
  fetch(`https://${GetParentResourceName()}/switchTab`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ tab: 'online' })
  });
});

tabDisconnected.addEventListener('click', () => {
  setActiveTab('disconnected');
  fetch(`https://${GetParentResourceName()}/switchTab`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ tab: 'disconnected' })
  });
});

document.addEventListener('keyup', (e) => {
  if (e.key === 'Escape') {
    panel.classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/close`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    });
  }
});
