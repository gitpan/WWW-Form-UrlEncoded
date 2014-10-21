#ifdef __cplusplus
extern "C" {
#endif

#define PERL_NO_GET_CONTEXT /* we want efficiency */
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#ifdef __cplusplus
} /* extern "C" */
#endif

#include "ppport.h"

static
void
split_kv(char *start, char *end, char **key, int *key_len, char **value, int *value_len) {
    char *cur = start;
    int found_eq = 0;
    if ( *cur == ' ' ) {
        cur++;
        start++;
    }
    while (cur != end) {
        if (*cur == '=') {
            found_eq = 1;
            *key = start;
            *key_len = cur - start;
            cur++;
            break;
        }
        cur++;
    }
    if (found_eq) {
        *value = cur;
        *value_len = end - cur;
    } else {
        *key = start;
        *key_len = end - start;
        *value_len = 0;
    }
}

static SV *
url_decode(pTHX_ const char *src, int src_len) {
    int dlen = 0, i = 0;
    char *d;
    char s2, s3;
    SV * dst;

    dst = newSV(0);
    (void)SvUPGRADE(dst, SVt_PV);
    d = SvGROW(dst, src_len * 3 + 1);

    for (i = 0; i < src_len; i++ ) {
        if (src[i] == '+'){
            d[dlen++] = ' ';
        }
        else if ( src[i] == '%' && isxdigit(src[i+1]) && isxdigit(src[i+2]) ) {
            s2 = src[i+1];
            s3 = src[i+2];
            s2 -= s2 <= '9' ? '0'
                : s2 <= 'F' ? 'A' - 10
                            : 'a' - 10;
            s3 -= s3 <= '9' ? '0'
                : s3 <= 'F' ? 'A' - 10
                            : 'a' - 10;
            d[dlen++] = s2 * 16 + s3;
            i += 2;
        }
        else {
            d[dlen++] = src[i];
        }
    }
    SvCUR_set(dst, dlen);
    SvPOK_only(dst);
    return dst;
}


MODULE = WWW::Form::UrlEncoded::XS    PACKAGE = WWW::Form::UrlEncoded::XS

PROTOTYPES: DISABLE

void
parse_urlencoded(qs)
    char *qs
PREINIT:
    char *cur = qs;
    char *prev = qs;
    char *key, *value;
    int key_len, value_len;
PPCODE:
    while (*cur != '\0') {
        if (*cur == '&' || *cur == ';') {
            split_kv(prev, cur, &key, &key_len, &value, &value_len);
            PUSHs(sv_2mortal(url_decode(aTHX_ key, key_len)));
            PUSHs(sv_2mortal(url_decode(aTHX_ value, value_len)));
            cur++;
            prev = cur;
        } else {
            cur++;
        }
    }

    if (prev != cur) {
        split_kv(prev, cur, &key, &key_len, &value, &value_len);
        PUSHs(sv_2mortal(url_decode(aTHX_ key, key_len)));
        PUSHs(sv_2mortal(url_decode(aTHX_ value, value_len)));
    }

    --cur;
    if ( *cur == '&' || *cur == ';' ) {
        PUSHs(sv_2mortal(newSVpv("",0)));
        PUSHs(sv_2mortal(newSVpv("",0)));
    }
