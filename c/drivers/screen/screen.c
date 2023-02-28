//*********************************************************
//---------------------------------------------------------
// CHADOS - C - screen.c
//
// Screen driver implemented in C for printing text
// to the screen using the VGA text buffer
//---------------------------------------------------------
//*********************************************************

#define VIDEO_ADDRESS 0xb8000

#define MAX_ROWS 25
#define MAX_COLS 80

#define DEFAULT_COLOR 0x0e

#define VGA_CTRL_REGISTER 0x3D4
#define VGA_DATA_REGISTER 0x3D5

#define VGA_OFFSET_LOW 0x0f
#define VGA_OFFSET_HIGH 0x0e

// external functions
unsigned char port_byte_in(unsigned short port);
void port_byte_out(unsigned short port, unsigned char data);
void c_memory_copy(char *source, char *dest, int quantity);

void c_set_cursor(unsigned int offset) {
  offset /= 2;
  port_byte_out(VGA_CTRL_REGISTER, VGA_OFFSET_HIGH);
  port_byte_out(VGA_DATA_REGISTER, (unsigned char)(offset >> 8));
  port_byte_out(VGA_CTRL_REGISTER, VGA_OFFSET_LOW);
  port_byte_out(VGA_DATA_REGISTER, (unsigned char)(offset & 0xff));
}

unsigned int c_get_cursor() {
  port_byte_out(VGA_CTRL_REGISTER, VGA_OFFSET_HIGH);

  unsigned int offset = port_byte_in(VGA_DATA_REGISTER) << 8;
  port_byte_out(VGA_CTRL_REGISTER, VGA_OFFSET_LOW);
  offset += port_byte_in(VGA_DATA_REGISTER);

  return offset * 2;
}

int get_row_from_offset(int offset) { return offset / (2 * MAX_COLS); }

int get_offset(int col, int row) { return 2 * (row * MAX_COLS + col); }

int move_offset_to_new_line(int offset) {
  return get_offset(0, get_row_from_offset(offset) + 1);
}

void c_print_byte(char character, unsigned int offset) {
  unsigned char *vidmem = (unsigned char *)VIDEO_ADDRESS;

  vidmem[offset] = character;
  vidmem[offset + 1] = DEFAULT_COLOR;
}

int scroll_ln(int offset) {
  c_memory_copy((char *)(get_offset(0, 1) + VIDEO_ADDRESS),
                (char *)(get_offset(0, 0) + VIDEO_ADDRESS),
                MAX_COLS * (MAX_ROWS - 1) * 2);

  for (int col = 0; col < MAX_COLS; col++) {
    c_print_byte(' ', get_offset(col, MAX_ROWS - 1));
  }

  return offset - 2 * MAX_COLS;
}

void c_print(char *string) {
  unsigned int offset = c_get_cursor();
  unsigned int i = 0;

  while (string[i] != 0) {
    if (offset >= MAX_ROWS * MAX_COLS * 2) {
      offset = scroll_ln(offset);
    }
    if (string[i] == '\n') {
      offset = move_offset_to_new_line(offset);
    } else {
      c_print_byte(string[i], offset);
      offset += 2;
    }
    i++;
  }

  c_set_cursor(offset);
}

void clear_screen() {
  for (int i = 0; i < MAX_COLS * MAX_ROWS; ++i) {
    c_print_byte(' ', i * 2);
  }
  c_set_cursor(get_offset(0, 0));
}
