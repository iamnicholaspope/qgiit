package com.ddwellers.app;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;

class NoteTest {

    @Test
    void trimsText() {
        assertThat(new Note("  hello  ").getText()).isEqualTo("hello");
    }

    @Test
    void rejectsBlankText() {
        assertThatThrownBy(() -> new Note("   ")).isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    void rejectsTooLongText() {
        String tooLong = "x".repeat(Note.MAX_LENGTH + 1);
        assertThatThrownBy(() -> new Note(tooLong)).isInstanceOf(IllegalArgumentException.class);
    }
}
