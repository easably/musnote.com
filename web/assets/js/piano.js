// Piano functionality
class PianoApp {
    constructor() {
        this.audioContext = null;
        this.oscillators = new Map();
        this.playedNotes = [];
        this.currentOctave = 4;
        this.volume = 0.7;
        this.init();
    }

    init() {
        this.setupAudioContext();
        this.createPianoKeys();
        this.setupEventListeners();
        this.setupChordHelper();
    }

    setupAudioContext() {
        try {
            this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
        } catch (error) {
            console.error('Web Audio API not supported:', error);
        }
    }

    createPianoKeys() {
        const keyboard = document.getElementById('piano-keyboard');
        if (!keyboard) return;

        // White keys
        const whiteKeys = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
        whiteKeys.forEach(note => {
            const key = document.createElement('div');
            key.className = 'piano-key white';
            key.dataset.note = note;
            key.textContent = note;
            key.addEventListener('mousedown', (e) => this.playNote(e));
            key.addEventListener('mouseup', (e) => this.stopNote(e));
            key.addEventListener('mouseleave', (e) => this.stopNote(e));
            keyboard.appendChild(key);
        });

        // Black keys
        const blackKeys = [
            { note: 'C#', position: 0 },
            { note: 'D#', position: 1 },
            { note: 'F#', position: 3 },
            { note: 'G#', position: 4 },
            { note: 'A#', position: 5 }
        ];

        blackKeys.forEach(({ note, position }) => {
            const key = document.createElement('div');
            key.className = 'piano-key black';
            key.dataset.note = note;
            key.textContent = note;
            key.style.left = `${position * 40 + 30}px`;
            key.addEventListener('mousedown', (e) => this.playNote(e));
            key.addEventListener('mouseup', (e) => this.stopNote(e));
            key.addEventListener('mouseleave', (e) => this.stopNote(e));
            keyboard.appendChild(key);
        });
    }

    setupEventListeners() {
        // Octave selector
        const octaveSelect = document.getElementById('octave-select');
        if (octaveSelect) {
            octaveSelect.addEventListener('change', (e) => {
                this.currentOctave = parseInt(e.target.value);
            });
        }

        // Volume control
        const volumeControl = document.getElementById('volume-control');
        const volumeDisplay = document.getElementById('volume-display');
        if (volumeControl && volumeDisplay) {
            volumeControl.addEventListener('input', (e) => {
                this.volume = e.target.value / 100;
                volumeDisplay.textContent = `${e.target.value}%`;
            });
        }

        // Clear notes button
        const clearNotes = document.getElementById('clear-notes');
        if (clearNotes) {
            clearNotes.addEventListener('click', () => {
                this.clearPlayedNotes();
            });
        }

        // Play chord button
        const playChord = document.getElementById('play-chord');
        if (playChord) {
            playChord.addEventListener('click', () => {
                this.playCMajorChord();
            });
        }

        // Keyboard support
        document.addEventListener('keydown', (e) => this.handleKeyboard(e));
        document.addEventListener('keyup', (e) => this.handleKeyboardRelease(e));
    }

    setupChordHelper() {
        const chordButtons = document.querySelectorAll('.chord-btn');
        chordButtons.forEach(btn => {
            btn.addEventListener('click', (e) => {
                const chord = e.target.dataset.chord;
                this.playChord(chord);
            });
        });
    }

    getFrequency(note, octave) {
        const noteFrequencies = {
            'C': 16.35,
            'C#': 17.32,
            'D': 18.35,
            'D#': 19.45,
            'E': 20.60,
            'F': 21.83,
            'F#': 23.12,
            'G': 24.50,
            'G#': 25.96,
            'A': 27.50,
            'A#': 29.14,
            'B': 30.87
        };

        const baseFreq = noteFrequencies[note];
        return baseFreq * Math.pow(2, octave);
    }

    playNote(event) {
        if (!this.audioContext) return;

        const note = event.target.dataset.note;
        const fullNote = `${note}${this.currentOctave}`;
        const frequency = this.getFrequency(note, this.currentOctave);

        // Stop any existing oscillator for this note
        this.stopNote(event);

        // Create new oscillator
        const oscillator = this.audioContext.createOscillator();
        const gainNode = this.audioContext.createGain();

        oscillator.connect(gainNode);
        gainNode.connect(this.audioContext.destination);

        oscillator.frequency.setValueAtTime(frequency, this.audioContext.currentTime);
        oscillator.type = 'sine';

        gainNode.gain.setValueAtTime(0, this.audioContext.currentTime);
        gainNode.gain.linearRampToValueAtTime(this.volume * 0.3, this.audioContext.currentTime + 0.01);

        oscillator.start();

        this.oscillators.set(fullNote, { oscillator, gainNode });

        // Visual feedback
        event.target.classList.add('active');

        // Add to played notes
        this.addPlayedNote(fullNote);
    }

    stopNote(event) {
        const note = event.target.dataset.note;
        const fullNote = `${note}${this.currentOctave}`;
        
        const oscillatorData = this.oscillators.get(fullNote);
        if (oscillatorData) {
            oscillatorData.gainNode.gain.exponentialRampToValueAtTime(0.001, this.audioContext.currentTime + 0.1);
            oscillatorData.oscillator.stop(this.audioContext.currentTime + 0.1);
            this.oscillators.delete(fullNote);
        }

        // Remove visual feedback
        event.target.classList.remove('active');
    }

    addPlayedNote(note) {
        this.playedNotes.push(note);
        this.updatePlayedNotesDisplay();
    }

    updatePlayedNotesDisplay() {
        const notesList = document.getElementById('played-notes');
        if (!notesList) return;

        notesList.innerHTML = this.playedNotes.map(note => 
            `<span class="note-item">${note}</span>`
        ).join('');
    }

    clearPlayedNotes() {
        this.playedNotes = [];
        this.updatePlayedNotesDisplay();
    }

    playCMajorChord() {
        const chordNotes = ['C', 'E', 'G'];
        chordNotes.forEach((note, index) => {
            setTimeout(() => {
                const frequency = this.getFrequency(note, this.currentOctave);
                this.playChordNote(note, frequency);
            }, index * 100);
        });
    }

    playChord(chord) {
        const chordNotes = {
            'C': ['C', 'E', 'G'],
            'D': ['D', 'F#', 'A'],
            'E': ['E', 'G#', 'B'],
            'F': ['F', 'A', 'C'],
            'G': ['G', 'B', 'D'],
            'A': ['A', 'C#', 'E'],
            'B': ['B', 'D#', 'F#']
        };

        const notes = chordNotes[chord];
        if (notes) {
            notes.forEach((note, index) => {
                setTimeout(() => {
                    const frequency = this.getFrequency(note, this.currentOctave);
                    this.playChordNote(note, frequency);
                }, index * 150);
            });
        }
    }

    playChordNote(note, frequency) {
        if (!this.audioContext) return;

        const oscillator = this.audioContext.createOscillator();
        const gainNode = this.audioContext.createGain();

        oscillator.connect(gainNode);
        gainNode.connect(this.audioContext.destination);

        oscillator.frequency.setValueAtTime(frequency, this.audioContext.currentTime);
        oscillator.type = 'sine';

        gainNode.gain.setValueAtTime(0, this.audioContext.currentTime);
        gainNode.gain.linearRampToValueAtTime(this.volume * 0.2, this.audioContext.currentTime + 0.01);
        gainNode.gain.exponentialRampToValueAtTime(0.001, this.audioContext.currentTime + 1);

        oscillator.start();
        oscillator.stop(this.audioContext.currentTime + 1);
    }

    handleKeyboard(event) {
        const keyMap = {
            'KeyA': 'C',
            'KeyS': 'D',
            'KeyD': 'E',
            'KeyF': 'F',
            'KeyG': 'G',
            'KeyH': 'A',
            'KeyJ': 'B',
            'KeyW': 'C#',
            'KeyE': 'D#',
            'KeyT': 'F#',
            'KeyY': 'G#',
            'KeyU': 'A#'
        };

        const note = keyMap[event.code];
        if (note && !event.repeat) {
            const keyElement = document.querySelector(`[data-note="${note}"]`);
            if (keyElement) {
                this.playNote({ target: keyElement });
            }
        }
    }

    handleKeyboardRelease(event) {
        const keyMap = {
            'KeyA': 'C',
            'KeyS': 'D',
            'KeyD': 'E',
            'KeyF': 'F',
            'KeyG': 'G',
            'KeyH': 'A',
            'KeyJ': 'B',
            'KeyW': 'C#',
            'KeyE': 'D#',
            'KeyT': 'F#',
            'KeyY': 'G#',
            'KeyU': 'A#'
        };

        const note = keyMap[event.code];
        if (note) {
            const keyElement = document.querySelector(`[data-note="${note}"]`);
            if (keyElement) {
                this.stopNote({ target: keyElement });
            }
        }
    }
}

// Initialize piano when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    // Initialize piano app
    window.pianoApp = new PianoApp();
});

// Export for testing
if (typeof module !== 'undefined' && module.exports) {
    module.exports = PianoApp;
}
