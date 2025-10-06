/**
 * Chord Tutorial JavaScript
 * Interactive chord tutorial with piano keyboard visualization
 */

class ChordTutorial {
    constructor() {
        this.audioContext = null;
        this.chordData = this.initializeChordData();
        this.currentChord = null;
        this.isPlaying = false;
        
        this.init();
    }

    init() {
        this.setupAudioContext();
        this.setupChordButtons();
        this.setupPianoKeyboard();
        this.setupKeyboardShortcuts();
    }

    initializeChordData() {
        return {
            // Major Chords
            'C': ['C4', 'E4', 'G4'],
            'D': ['D4', 'F#4', 'A4'],
            'E': ['E4', 'G#4', 'B4'],
            'F': ['F4', 'A4', 'C5'],
            'G': ['G4', 'B4', 'D5'],
            'A': ['A4', 'C#5', 'E5'],
            'B': ['B4', 'D#5', 'F#5'],
            
            // Minor Chords
            'Cm': ['C4', 'D#4', 'G4'],
            'Dm': ['D4', 'F4', 'A4'],
            'Em': ['E4', 'G4', 'B4'],
            'Fm': ['F4', 'G#4', 'C5'],
            'Gm': ['G4', 'A#4', 'D5'],
            'Am': ['A4', 'C5', 'E5'],
            'Bm': ['B4', 'D5', 'F#5'],
            
            // Seventh Chords
            'C7': ['C4', 'E4', 'G4', 'A#4'],
            'D7': ['D4', 'F#4', 'A4', 'C5'],
            'E7': ['E4', 'G#4', 'B4', 'D5'],
            'F7': ['F4', 'A4', 'C5', 'D#5'],
            'G7': ['G4', 'B4', 'D5', 'F5'],
            'A7': ['A4', 'C#5', 'E5', 'G5'],
            'B7': ['B4', 'D#5', 'F#5', 'A5']
        };
    }

    setupAudioContext() {
        try {
            this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
        } catch (error) {
            console.warn('Web Audio API not supported:', error);
        }
    }

    setupChordButtons() {
        const chordButtons = document.querySelectorAll('.chord-btn');
        
        chordButtons.forEach(button => {
            button.addEventListener('click', () => {
                const chord = button.dataset.chord;
                this.selectChord(chord);
            });
        });
    }

    setupPianoKeyboard() {
        const pianoKeys = document.querySelectorAll('.piano-key');
        
        pianoKeys.forEach(key => {
            key.addEventListener('click', () => {
                const note = key.dataset.note;
                this.playNote(note);
                this.highlightKey(key);
            });
        });
    }

    setupKeyboardShortcuts() {
        document.addEventListener('keydown', (event) => {
            const keyMap = {
                'a': 'C4', 's': 'D4', 'd': 'E4', 'f': 'F4', 'g': 'G4', 'h': 'A4', 'j': 'B4',
                'w': 'C#4', 'e': 'D#4', 't': 'F#4', 'y': 'G#4', 'u': 'A#4'
            };
            
            const note = keyMap[event.key.toLowerCase()];
            if (note) {
                event.preventDefault();
                this.playNote(note);
                this.highlightKeyByNote(note);
            }
        });
    }

    selectChord(chordName) {
        // Remove active class from all chord buttons
        document.querySelectorAll('.chord-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        
        // Add active class to selected chord button
        const selectedButton = document.querySelector(`[data-chord="${chordName}"]`);
        if (selectedButton) {
            selectedButton.classList.add('active');
        }
        
        // Clear previous chord highlighting
        this.clearChordHighlighting();
        
        // Get chord notes
        const chordNotes = this.chordData[chordName];
        if (!chordNotes) {
            console.warn(`Chord ${chordName} not found`);
            return;
        }
        
        // Highlight chord notes on piano
        chordNotes.forEach(note => {
            const key = document.querySelector(`[data-note="${note}"]`);
            if (key) {
                key.classList.add('active', 'chord-highlight');
            }
        });
        
        // Update chord info
        this.updateChordInfo(chordName, chordNotes);
        
        // Play chord
        this.playChord(chordNotes);
        
        this.currentChord = chordName;
    }

    clearChordHighlighting() {
        document.querySelectorAll('.piano-key').forEach(key => {
            key.classList.remove('active', 'chord-highlight');
        });
    }

    updateChordInfo(chordName, notes) {
        const chordNameElement = document.getElementById('current-chord-name');
        const chordNotesElement = document.getElementById('chord-notes');
        
        if (chordNameElement) {
            chordNameElement.textContent = chordName;
        }
        
        if (chordNotesElement) {
            chordNotesElement.innerHTML = '';
            notes.forEach(note => {
                const noteElement = document.createElement('span');
                noteElement.className = 'chord-note';
                noteElement.textContent = note;
                chordNotesElement.appendChild(noteElement);
            });
        }
    }

    playChord(notes) {
        if (!this.audioContext || this.isPlaying) return;
        
        this.isPlaying = true;
        
        notes.forEach((note, index) => {
            setTimeout(() => {
                this.playNote(note);
            }, index * 100); // Stagger the notes slightly
        });
        
        setTimeout(() => {
            this.isPlaying = false;
        }, notes.length * 100 + 500);
    }

    playNote(note) {
        if (!this.audioContext) return;
        
        const frequency = this.getNoteFrequency(note);
        const oscillator = this.audioContext.createOscillator();
        const gainNode = this.audioContext.createGain();
        
        oscillator.connect(gainNode);
        gainNode.connect(this.audioContext.destination);
        
        oscillator.frequency.setValueAtTime(frequency, this.audioContext.currentTime);
        oscillator.type = 'sine';
        
        // Envelope for natural sound
        gainNode.gain.setValueAtTime(0, this.audioContext.currentTime);
        gainNode.gain.linearRampToValueAtTime(0.3, this.audioContext.currentTime + 0.01);
        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 1);
        
        oscillator.start(this.audioContext.currentTime);
        oscillator.stop(this.audioContext.currentTime + 1);
    }

    getNoteFrequency(note) {
        const noteFrequencies = {
            'C4': 261.63, 'C#4': 277.18, 'D4': 293.66, 'D#4': 311.13, 'E4': 329.63,
            'F4': 349.23, 'F#4': 369.99, 'G4': 392.00, 'G#4': 415.30, 'A4': 440.00,
            'A#4': 466.16, 'B4': 493.88,
            'C5': 523.25, 'C#5': 554.37, 'D5': 587.33, 'D#5': 622.25, 'E5': 659.25,
            'F5': 698.46, 'F#5': 739.99, 'G5': 783.99, 'G#5': 830.61, 'A5': 880.00,
            'A#5': 932.33, 'B5': 987.77,
            'C6': 1046.50
        };
        
        return noteFrequencies[note] || 440;
    }

    highlightKey(key) {
        key.classList.add('active');
        setTimeout(() => {
            key.classList.remove('active');
        }, 200);
    }

    highlightKeyByNote(note) {
        const key = document.querySelector(`[data-note="${note}"]`);
        if (key) {
            this.highlightKey(key);
        }
    }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new ChordTutorial();
});

// Handle language switching
document.addEventListener('languageChanged', (event) => {
    // Re-initialize chord tutorial if needed
    const chordTutorial = new ChordTutorial();
});
