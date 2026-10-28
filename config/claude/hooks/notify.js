#!/usr/bin/env node
/**
 * Notify - PermissionRequest / Notification / Stop hook
 * Shows a project-scoped macOS notification describing what Claude needs.
 * Logs to: ~/.claude/hooks-logs/
 *
 * Setup in settings.json:
 * {
 *   "hooks": {
 *     "PermissionRequest": [{ "matcher": "", "hooks": [{ "type": "command", "command": "node /path/to/notify.js" }] }],
 *     "Notification":      [{ "matcher": "", "hooks": [{ "type": "command", "command": "node /path/to/notify.js" }] }],
 *     "Stop":              [{ "matcher": "", "hooks": [{ "type": "command", "command": "node /path/to/notify.js" }] }]
 *   }
 * }
 */

const fs = require('fs');
const path = require('path');
const { execFile } = require('child_process');

const LOG_DIR = path.join(process.env.HOME, '.claude', 'hooks-logs');
const TERMINAL_NOTIFIER = '/opt/homebrew/bin/terminal-notifier';

function log(data) {
  try {
    if (!fs.existsSync(LOG_DIR)) fs.mkdirSync(LOG_DIR, { recursive: true });
    const file = path.join(LOG_DIR, `${new Date().toISOString().slice(0, 10)}.jsonl`);
    fs.appendFileSync(file, JSON.stringify({ ts: new Date().toISOString(), hook: 'notify', ...data }) + '\n');
  } catch {}
}

function notify(title, message, group) {
  execFile(TERMINAL_NOTIFIER, ['-title', title, '-message', message, '-group', group || 'claude-code'], () => {});
}

function buildNotification(data) {
  const project = path.basename(data.cwd || process.cwd() || '');

  switch (data.hook_event_name) {
    case 'PermissionRequest': {
      const detail = data.tool_input?.command || data.tool_input?.file_path || '';
      return {
        title: `🔐 ${project} — approval needed`,
        message: detail ? `${data.tool_name}: ${detail}` : (data.tool_name || 'Tool call'),
      };
    }
    case 'Notification': {
      if (data.notification_type === 'agent_needs_input') {
        return { title: `⌨️ ${project} — input needed`, message: data.message || '' };
      }
      return { title: `💬 ${project}`, message: data.message || '' };
    }
    case 'Stop': {
      const text = (data.last_assistant_message || '').slice(0, 100);
      return { title: `✅ ${project} — done`, message: text };
    }
    default:
      return null;
  }
}

async function main() {
  let input = '';
  for await (const chunk of process.stdin) input += chunk;

  try {
    const data = JSON.parse(input);
    const built = buildNotification(data);

    if (!built) {
      log({ level: 'SKIP', reason: 'unhandled event', event: data.hook_event_name });
      return console.log('{}');
    }

    notify(built.title, built.message, data.session_id);
    log({ level: 'SENT', event: data.hook_event_name, title: built.title, message: built.message, session_id: data.session_id });

    console.log('{}');
  } catch (e) {
    log({ level: 'ERROR', error: e.message });
    console.log('{}');
  }
}

if (require.main === module) {
  main();
} else {
  module.exports = { buildNotification };
}
