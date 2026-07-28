/**
 * FreeDubbing API client for MusNote tools.
 * Default: https://api.freedubbing.com (override with window.MUSNOTE_API_BASE).
 */
(function (global) {
  const API_BASE = (global.MUSNOTE_API_BASE || 'https://api.freedubbing.com').replace(/\/$/, '');

  function httpsUrl(url) {
    if (!url) return url;
    return String(url).replace(/^http:\/\//i, 'https://');
  }

  async function readError(res) {
    let detail = res.statusText || 'Request failed';
    try {
      const data = await res.json();
      detail = data.detail || data.message || data.error || JSON.stringify(data);
    } catch (_) {
      try {
        detail = await res.text();
      } catch (_) {}
    }
    const err = new Error(typeof detail === 'string' ? detail : JSON.stringify(detail));
    err.status = res.status;
    throw err;
  }

  /**
   * TTS with adjustable speed (Kokoro). Returns a playable object URL (WAV).
   * speed: 0.5–2.0
   */
  async function synthesizeSpeech({
    text,
    language = 'en-us',
    voice = 'female',
    speed = 1.0,
  }) {
    const res = await fetch(`${API_BASE}/audio/generate?provider=local`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Client-App': 'musnote-web',
      },
      body: JSON.stringify({
        text: String(text || '').trim(),
        language,
        voice,
        speed: Math.min(2, Math.max(0.5, Number(speed) || 1)),
      }),
    });
    if (!res.ok) await readError(res);
    const blob = await res.blob();
    return {
      blob,
      objectUrl: URL.createObjectURL(blob),
      contentType: res.headers.get('content-type') || 'audio/wav',
    };
  }

  /**
   * TTS v3 (phrase). Returns remote WAV URL (forced https).
   */
  async function synthesizeSpeechV3({
    text,
    lang = 'en',
    accent = 'us',
    gender = 'female',
  }) {
    const res = await fetch(`${API_BASE}/audio/v3/tts`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Client-App': 'musnote-web',
      },
      body: JSON.stringify({
        text: String(text || '').trim(),
        lang,
        accent,
        gender,
        write_to_cdn: false,
      }),
    });
    if (!res.ok) await readError(res);
    const data = await res.json();
    const url = httpsUrl(data?.data?.url || data?.url);
    if (!url) throw new Error('TTS returned no audio URL');
    return { url, raw: data };
  }

  /**
   * STT via Whisper. Pass exactly one of: file, url, audioBase64.
   */
  async function speechToText({ file, url, audioBase64 } = {}) {
    let res;
    if (file) {
      const form = new FormData();
      form.append('file', file, file.name || 'audio.wav');
      res = await fetch(`${API_BASE}/audio-timing/process`, {
        method: 'POST',
        headers: { 'X-Client-App': 'musnote-web' },
        body: form,
      });
    } else if (url || audioBase64) {
      const body = url ? { url } : { audio_base64: audioBase64 };
      res = await fetch(`${API_BASE}/audio-timing/process`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Client-App': 'musnote-web',
        },
        body: JSON.stringify(body),
      });
    } else {
      throw new Error('Provide a file, URL, or base64 audio');
    }
    if (!res.ok) await readError(res);
    const data = await res.json();
    return {
      text: data.text || '',
      language: data.language || data.lang || '',
      duration: data.duration,
      segments: data.segments || [],
      task: data.task,
      raw: data,
    };
  }

  global.MusnoteApi = {
    API_BASE,
    httpsUrl,
    synthesizeSpeech,
    synthesizeSpeechV3,
    speechToText,
  };
})(window);
