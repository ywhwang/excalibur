#define PRINT_STRING            screen_monitor_write_string
#define PRINT_UINT32            screen_monitor_write_uint32
#define PRINT_UINT32_HEX        screen_monitor_write_uint32_hex

#include "print_internal.c"

void
printf_vga(char *format, ...)
{
    void *param;

    if (format && ('\0' != *format)) {
        param = (void *)&format + sizeof(format);
        printf_k(format, param);
    }
}

void
printf_vga_ts(char *format, ...)
{
    void *param;
    uint32 ts;

    if (format && ('\0' != *format)) {
        ts = (uint32)time_stamp_counter();
        printf_vga("[%x] ", ts);

        param = (void *)&format + sizeof(format);
        printf_k(format, param);
    }
}

#undef PRINT_STRING
#undef PRINT_UINT32
#undef PRINT_UINT32_HEX

