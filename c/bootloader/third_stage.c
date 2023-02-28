//*********************************************************
//---------------------------------------------------------
// CHADOS - C - kernel.c
//
// The ChadOS Kernel implemented in C.
// This is where the bootloader gives control
//---------------------------------------------------------
//*********************************************************

extern void c_print(char byte[]); // C
extern void clear_screen();

void third_stage() {
  char str[] = "By default, Rust code generated for this target does not use";

  c_print(str);
  // r_set_cursor(5);

  for (;;) {
  }
}

void doit() {
  for (;;) {
  }
}