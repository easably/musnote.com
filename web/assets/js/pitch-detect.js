/**
 * Lightweight browser pitch helpers for octave / range tools.
 */
(function (global) {
  const NOTE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];

  function frequencyToMidi(freq) {
    return 69 + 12 * Math.log2(freq / 440);
  }

  function midiToNoteName(midi) {
    const rounded = Math.round(midi);
    const name = NOTE_NAMES[((rounded % 12) + 12) % 12];
    const octave = Math.floor(rounded / 12) - 1;
    return { midi: rounded, name, octave, label: `${name}${octave}` };
  }

  function midiToFrequency(midi) {
    return 440 * Math.pow(2, (midi - 69) / 12);
  }

  /** Autocorrelation pitch estimate (Hz) or null. */
  function detectPitch(float32Array, sampleRate, { minHz = 70, maxHz = 1000 } = {}) {
    const buf = float32Array;
    const size = buf.length;
    if (size < 512) return null;

    let rms = 0;
    for (let i = 0; i < size; i++) rms += buf[i] * buf[i];
    rms = Math.sqrt(rms / size);
    if (rms < 0.01) return null;

    const maxLag = Math.floor(sampleRate / minHz);
    const minLag = Math.floor(sampleRate / maxHz);
    let bestLag = -1;
    let bestCorr = 0;

    for (let lag = minLag; lag <= maxLag; lag++) {
      let corr = 0;
      for (let i = 0; i < size - lag; i++) {
        corr += buf[i] * buf[i + lag];
      }
      if (corr > bestCorr) {
        bestCorr = corr;
        bestLag = lag;
      }
    }

    if (bestLag <= 0 || bestCorr < 0.01) return null;
    return sampleRate / bestLag;
  }

  class LivePitchMonitor {
    constructor(onFrame) {
      this.onFrame = onFrame;
      this._running = false;
      this._raf = null;
      this._ctx = null;
      this._stream = null;
      this._analyser = null;
      this._data = null;
    }

    async start() {
      if (this._running) return;
      this._stream = await navigator.mediaDevices.getUserMedia({
        audio: {
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: true,
        },
      });
      this._ctx = new (window.AudioContext || window.webkitAudioContext)();
      const source = this._ctx.createMediaStreamSource(this._stream);
      this._analyser = this._ctx.createAnalyser();
      this._analyser.fftSize = 2048;
      source.connect(this._analyser);
      this._data = new Float32Array(this._analyser.fftSize);
      this._running = true;
      const tick = () => {
        if (!this._running) return;
        this._analyser.getFloatTimeDomainData(this._data);
        const freq = detectPitch(this._data, this._ctx.sampleRate);
        if (freq && this.onFrame) {
          const midi = frequencyToMidi(freq);
          this.onFrame({ freq, midi, note: midiToNoteName(midi) });
        } else if (this.onFrame) {
          this.onFrame({ freq: null, midi: null, note: null });
        }
        this._raf = requestAnimationFrame(tick);
      };
      tick();
    }

    stop() {
      this._running = false;
      if (this._raf) cancelAnimationFrame(this._raf);
      if (this._stream) this._stream.getTracks().forEach((t) => t.stop());
      if (this._ctx) this._ctx.close().catch(() => {});
      this._stream = null;
      this._ctx = null;
    }
  }

  /**
   * Sample pitches from an AudioBuffer (offline-ish walk).
   * Returns { minMidi, maxMidi, medianMidi, samples }.
   */
  function analyzeBufferRange(audioBuffer, { hop = 2048, frame = 2048 } = {}) {
    const channel = audioBuffer.getChannelData(0);
    const rate = audioBuffer.sampleRate;
    const midis = [];
    for (let i = 0; i + frame < channel.length; i += hop) {
      const slice = channel.subarray(i, i + frame);
      const freq = detectPitch(slice, rate);
      if (freq) {
        const midi = frequencyToMidi(freq);
        if (midi > 36 && midi < 96) midis.push(midi);
      }
    }
    if (!midis.length) return null;
    midis.sort((a, b) => a - b);
    const minMidi = midis[Math.floor(midis.length * 0.1)];
    const maxMidi = midis[Math.floor(midis.length * 0.9)];
    const medianMidi = midis[Math.floor(midis.length * 0.5)];
    return { minMidi, maxMidi, medianMidi, samples: midis.length };
  }

  /** Play buffer pitched by semitoneDelta (via playbackRate ≈ 2^(n/12)). */
  async function playPitched(audioBuffer, semitoneDelta) {
    const ctx = new (window.AudioContext || window.webkitAudioContext)();
    const source = ctx.createBufferSource();
    source.buffer = audioBuffer;
    source.playbackRate.value = Math.pow(2, semitoneDelta / 12);
    source.connect(ctx.destination);
    source.start(0);
    return {
      ctx,
      source,
      stop() {
        try {
          source.stop();
        } catch (_) {}
        ctx.close().catch(() => {});
      },
    };
  }

  global.MusnotePitch = {
    NOTE_NAMES,
    frequencyToMidi,
    midiToNoteName,
    midiToFrequency,
    detectPitch,
    LivePitchMonitor,
    analyzeBufferRange,
    playPitched,
  };
})(window);
