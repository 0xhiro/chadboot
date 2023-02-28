//*********************************************************
//---------------------------------------------------------
// CHADOS - C - serial.c
//
// Driver for communicating with hardware serial ports
// implemented in C
//---------------------------------------------------------
//*********************************************************

unsigned char port_byte_in(unsigned short port) {
  unsigned char result;

  __asm__("in al, dx" : "=a"(result) : "d"(port));

  return result;
}

void port_byte_out(unsigned short port, unsigned char data) {
  __asm__("out dx, al" : : "a"(data), "d"(port));
}

unsigned short port_word_in(unsigned short port) {
  unsigned short result;

  __asm__("in ax, dx" : "=a"(result) : "a"(port));

  return result;
}

void port_word_out(unsigned short port, unsigned short data) {
  __asm__("out dx, ax" : : "a"(data), "d"(port));
}