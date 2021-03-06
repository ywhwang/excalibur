static inline void
printf_k(char *format, void *param)
{
     uint32 len;
     char buf[PR_BUF_SIZE + 1];

     kassert(NULL != format);
     kassert(NULL != param);

     buf[PR_BUF_SIZE] = '\0';
     len = string_len_k(format);

     while (len > PR_BUF_SIZE) {
         kmemory_copy(buf, format, PR_BUF_SIZE);
         param = printf_k_one_buf(buf, param);
         len -= PR_BUF_SIZE;
         format += PR_BUF_SIZE;
     }

     if (len) {
         kmemory_copy(buf, format, len);
         printf_k_one_buf(buf, param);
     }
}

static inline void *
printf_k_one_buf(char *buf, void *base)
{
    char *s;
    char *trvl;

    kassert(NULL != buf);
    kassert(NULL != base);

    s = buf;
    trvl = buf;

    while ('\0' != *trvl) {
        if ('%' == *trvl) {
            *trvl = CHAR_NULL;
            PRINT_STRING(s);

            trvl++;
            switch (*trvl) {
                case 'd':
                    PRINT_UINT32(*(uint32 *)base);
                    base += sizeof(uint32);
                    break;
                case 'x':
                    PRINT_UINT32_HEX(*(uint32 *)base);
                    base += sizeof(uint32);
                    break;
                case 's':
                    PRINT_STRING(*(char **)base);
                    base += sizeof(char *);
                    break;
                default:
                    break;
            }
            s = trvl + 1;
        }
        trvl++;
    }

    PRINT_STRING(s);

    return base;
}

