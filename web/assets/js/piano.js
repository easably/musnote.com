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

    ensureAudioContext() {
        if (!this.audioContext) {
            this.setupAudioContext();
        }
        
        // Resume audio context if suspended (required by some browsers)
        if (this.audioContext && this.audioContext.state === 'suspended') {
            this.audioContext.resume();
        }
    }

    createPianoKeys() {
        const keyboard = document.getElementById('piano-keyboard');
        if (!keyboard) return;

        // Clear existing keys
        keyboard.innerHTML = '';

        // Create full piano keyboard (3 octaves: C3 to C6)
        const octaves = [3, 4, 5];
        const whiteKeys = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
        const blackKeys = [
            { note: 'C#', position: 0 },
            { note: 'D#', position: 1 },
            { note: 'F#', position: 3 },
            { note: 'G#', position: 4 },
            { note: 'A#', position: 5 }
        ];

        let keyIndex = 0;

        octaves.forEach(octave => {
            // Create white keys for this octave
            whiteKeys.forEach(note => {
                const key = document.createElement('div');
                key.className = 'piano-key white';
                key.dataset.note = `${note}${octave}`;
                key.dataset.octave = octave;
                key.textContent = note;
                key.style.left = `${keyIndex * 60}px`;
                key.addEventListener('mousedown', (e) => this.playNote(e));
                key.addEventListener('mouseup', (e) => this.stopNote(e));
                key.addEventListener('mouseleave', (e) => this.stopNote(e));
                keyboard.appendChild(key);
                keyIndex++;
            });

            // Create black keys for this octave
            blackKeys.forEach(({ note, position }) => {
                const key = document.createElement('div');
                key.className = 'piano-key black';
                key.dataset.note = `${note}${octave}`;
                key.dataset.octave = octave;
                key.textContent = note;
                key.style.left = `${(keyIndex - 7 + position) * 60 + 45}px`;
                key.addEventListener('mousedown', (e) => this.playNote(e));
                key.addEventListener('mouseup', (e) => this.stopNote(e));
                key.addEventListener('mouseleave', (e) => this.stopNote(e));
                keyboard.appendChild(key);
            });
        });

        // Update keyboard width
        keyboard.style.width = `${keyIndex * 60}px`;
    }

    setupEventListeners() {
        // Initialize audio context on first user interaction
        document.addEventListener('click', () => {
            this.ensureAudioContext();
        }, { once: true });

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
        // Standard frequencies for A4 = 440Hz
        const noteFrequencies = {
            'C': 261.63,   // C4
            'C#': 277.18,  // C#4
            'D': 293.66,    // D4
            'D#': 311.13,  // D#4
            'E': 329.63,   // E4
            'F': 349.23,   // F4
            'F#': 369.99,  // F#4
            'G': 392.00,   // G4
            'G#': 415.30,  // G#4
            'A': 440.00,   // A4
            'A#': 466.16,  // A#4
            'B': 493.88    // B4
        };

        const baseFreq = noteFrequencies[note];
        if (!baseFreq) {
            console.warn(`Unknown note: ${note}`);
            return 440; // Default to A4
        }
        
        // Calculate frequency based on octave difference from 4
        const octaveDiff = octave - 4;
        const frequency = baseFreq * Math.pow(2, octaveDiff);
        
        // Validate frequency
        if (!isFinite(frequency) || frequency <= 0) {
            console.warn(`Invalid frequency for ${note}${octave}: ${frequency}`);
            return 440; // Default to A4
        }
        
        return frequency;
    }

    playNote(event) {
        this.ensureAudioContext();
        if (!this.audioContext) return;

        const fullNote = event.target.dataset.note; // e.g., "C3", "C4", "C5"
        const octave = parseInt(event.target.dataset.octave) || this.currentOctave;
        
        // Extract note name from full note (remove octave number)
        let note = fullNote.replace(/\d+$/, ''); // Remove trailing digits
        
        // Fallback: if regex didn't work, try manual extraction
        if (note === fullNote) {
            // Extract note name manually (e.g., "C#4" -> "C#")
            const match = fullNote.match(/^([A-G]#?)/);
            if (match) {
                note = match[1];
            }
        }
        const frequency = this.getFrequency(note, octave);

        // Debug: log the note and frequency
        console.log(`Full note: ${fullNote}, extracted note: ${note}, octave: ${octave}, frequency: ${frequency}Hz`);

        // Validate frequency before playing
        if (!isFinite(frequency) || frequency <= 0 || frequency > 20000) {
            console.warn(`Invalid frequency for ${note}${octave}: ${frequency}`);
            return;
        }

        // Stop any existing oscillator for this note
        this.stopNote(event);

        try {
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
        } catch (error) {
            console.error('Error playing note:', error);
        }
    }

    stopNote(event) {
        const fullNote = event.target.dataset.note; // e.g., "C3", "C4", "C5"
        
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
        
        // Stop all oscillators
        this.oscillators.forEach(({ oscillator, gainNode }) => {
            try {
                gainNode.gain.exponentialRampToValueAtTime(0.001, this.audioContext.currentTime + 0.1);
                oscillator.stop(this.audioContext.currentTime + 0.1);
            } catch (error) {
                console.warn('Error stopping oscillator:', error);
            }
        });
        this.oscillators.clear();
        
        // Remove visual feedback from all keys
        const keyboard = document.getElementById('piano-keyboard');
        if (keyboard) {
            const activeKeys = keyboard.querySelectorAll('.active');
            activeKeys.forEach(key => key.classList.remove('active'));
            
            // Also clear chord highlights
            this.clearChordHighlights();
        }
    }

    playCMajorChord() {
        const chordNotes = ['C', 'E', 'G'];
        
        // Clear previous chord highlights
        this.clearChordHighlights();
        
        // Highlight all chord keys immediately
        this.highlightChordKeys(chordNotes);
        
        // Play notes with delay
        chordNotes.forEach((note, index) => {
            setTimeout(() => {
                const frequency = this.getFrequency(note, this.currentOctave);
                this.playChordNote(note, frequency);
            }, index * 100);
        });
        
        // Clear highlights after animation
        setTimeout(() => {
            this.clearChordHighlights();
        }, chordNotes.length * 100 + 1000);
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
            // Clear previous chord highlights
            this.clearChordHighlights();
            
            // Highlight all chord keys immediately
            this.highlightChordKeys(notes);
            
            // Play notes with delay
            notes.forEach((note, index) => {
                setTimeout(() => {
                    const frequency = this.getFrequency(note, this.currentOctave);
                    this.playChordNote(note, frequency);
                }, index * 150);
            });
            
            // Clear highlights after animation
            setTimeout(() => {
                this.clearChordHighlights();
            }, notes.length * 150 + 1000);
        }
    }

    highlightChordKeys(notes) {
        const keyboard = document.getElementById('piano-keyboard');
        if (!keyboard) return;

        notes.forEach(note => {
            // Find all keys with this note across all octaves
            const keys = keyboard.querySelectorAll(`[data-note="${note}3"], [data-note="${note}4"], [data-note="${note}5"]`);
            keys.forEach(key => {
                key.classList.add('chord-highlight');
            });
        });
    }

    clearChordHighlights() {
        const keyboard = document.getElementById('piano-keyboard');
        if (!keyboard) return;

        const highlightedKeys = keyboard.querySelectorAll('.chord-highlight');
        highlightedKeys.forEach(key => {
            key.classList.remove('chord-highlight');
        });
    }

    playChordNote(note, frequency) {
        this.ensureAudioContext();
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
