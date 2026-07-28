(function () {
  const liveNote = document.getElementById('live-note');
  const lowNote = document.getElementById('low-note');
  const highNote = document.getElementById('high-note');
  const centerNote = document.getElementById('center-note');
  const refCenterEl = document.getElementById('ref-center');
  const semitonesEl = document.getElementById('semitones');
  const manualShift = document.getElementById('manual-shift');
  const manualVal = document.getElementById('manual-val');
  const statusEl = document.getElementById('status');

  let monitor = null;
  let minMidi = null;
  let maxMidi = null;
  let userCenter = null;
  let refBuffer = null;
  let refCenter = null;
  let suggestedShift = 0;
  let playing = null;

  function setStatus(kind, message) {
    statusEl.className = `tool-status is-visible ${kind}`;
    statusEl.textContent = message;
  }

  function labelMidi(midi) {
    if (midi == null) return '—';
    return MusnotePitch.midiToNoteName(midi).label;
  }

  function updateUserStats() {
    lowNote.textContent = labelMidi(minMidi);
    highNote.textContent = labelMidi(maxMidi);
    if (minMidi != null && maxMidi != null) {
      userCenter = (minMidi + maxMidi) / 2;
      centerNote.textContent = labelMidi(userCenter);
      recomputeShift();
    }
  }

  function recomputeShift() {
    if (userCenter == null || refCenter == null) {
      semitonesEl.textContent = '—';
      return;
    }
    suggestedShift = Math.round(userCenter - refCenter);
    const total = suggestedShift + Number(manualShift.value);
    semitonesEl.textContent = (total >= 0 ? '+' : '') + total;
  }

  manualShift.addEventListener('input', () => {
    manualVal.textContent = manualShift.value;
    recomputeShift();
  });

  document.getElementById('btn-mic-start').addEventListener('click', async () => {
    try {
      monitor = new MusnotePitch.LivePitchMonitor(({ note, midi }) => {
        if (!note) {
          liveNote.textContent = '…';
          return;
        }
        liveNote.textContent = note.label;
        if (minMidi == null || midi < minMidi) minMidi = midi;
        if (maxMidi == null || midi > maxMidi) maxMidi = midi;
        updateUserStats();
      });
      await monitor.start();
      document.getElementById('btn-mic-start').disabled = true;
      document.getElementById('btn-mic-stop').disabled = false;
      setStatus('info', 'Listening — explore your comfortable low and high notes.');
    } catch (err) {
      setStatus('error', err.message || 'Microphone permission denied.');
    }
  });

  document.getElementById('btn-mic-stop').addEventListener('click', () => {
    if (monitor) monitor.stop();
    monitor = null;
    document.getElementById('btn-mic-start').disabled = false;
    document.getElementById('btn-mic-stop').disabled = true;
    setStatus('ok', 'Mic stopped. Range saved in this session.');
  });

  document.getElementById('btn-mic-reset').addEventListener('click', () => {
    minMidi = maxMidi = userCenter = null;
    updateUserStats();
    liveNote.textContent = '—';
    recomputeShift();
  });

  document.getElementById('ref-file').addEventListener('change', () => {
    document.getElementById('btn-analyze').disabled = !document.getElementById('ref-file').files?.[0];
  });

  document.getElementById('btn-analyze').addEventListener('click', async () => {
    const file = document.getElementById('ref-file').files?.[0];
    if (!file) return;
    setStatus('info', 'Analyzing pitch of reference clip…');
    try {
      const arrayBuf = await file.arrayBuffer();
      const ctx = new (window.AudioContext || window.webkitAudioContext)();
      refBuffer = await ctx.decodeAudioData(arrayBuf.slice(0));
      await ctx.close();
      const range = MusnotePitch.analyzeBufferRange(refBuffer);
      if (!range) {
        setStatus('error', 'Could not detect pitched content. Try a clearer vocal clip.');
        return;
      }
      refCenter = range.medianMidi;
      refCenterEl.textContent = labelMidi(refCenter);
      recomputeShift();
      document.getElementById('btn-play-orig').disabled = false;
      document.getElementById('btn-play-shifted').disabled = false;
      document.getElementById('btn-stop-audio').disabled = false;
      setStatus('ok', `Clip analyzed (${range.samples} pitch samples).`);
    } catch (err) {
      setStatus('error', err.message || String(err));
    }
  });

  async function play(shift) {
    if (!refBuffer) return;
    if (playing) playing.stop();
    playing = await MusnotePitch.playPitched(refBuffer, shift);
  }

  document.getElementById('btn-play-orig').addEventListener('click', () => play(0));
  document.getElementById('btn-play-shifted').addEventListener('click', () => {
    if (userCenter == null || refCenter == null) {
      setStatus('error', 'Detect your range first, then analyze a clip.');
      return;
    }
    play(suggestedShift + Number(manualShift.value));
  });
  document.getElementById('btn-stop-audio').addEventListener('click', () => {
    if (playing) playing.stop();
    playing = null;
  });
})();
