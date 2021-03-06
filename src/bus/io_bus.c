void
io_bus_write_byte(uint16 port, uint8 val)
{
    asm volatile (
        "outb %1, %0\n\t"
        :
        :"dN"(port), "a"(val));
    /*
     * N: Constant in range 0 to 255, x86 platform only
     */
}

uint8
io_bus_read_byte(uint16 port)
{
    uint8 retval;

    asm volatile (
        "inb %1, %0\n\t"
        :"=a"(retval)
        :"dN"(port));

    return retval;
}

uint16
io_bus_read_word(uint16 port)
{
    uint16 retval;

    asm volatile (
        "inw %1, %0\n\t"
        :"=a"(retval)
        :"dN"(port));

    return retval;
}

