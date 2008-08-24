#!/usr/bin/perl

while(<>) {
#     s/^#line.*//;
#     s/.*Revision:.*//;
#     s/.*Date:.*//;
#     s/.*Header:.*//;

    # substitution to replace [yylval] with SAT_[yylval]
    s/yylval/SAT_yylval/g;

    s/YY_DO_BEFORE_ACTION;/YY_DO_BEFORE_ACTION/;
    s/^(\s)+;$/$1do {} while(0);/;

    s/#if YY_STACK_USED/#ifdef YY_STACK_USED/;
    s/#if YY_ALWAYS_INTERACTIVE/#ifdef YY_ALWAYS_INTERACTIVE/;
    s/#if YY_MAIN/#ifdef YY_MAIN/;

    print $_;
}
