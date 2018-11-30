#!/bin/sh

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

KHORIUMD=${KHORIUMD:-$SRCDIR/khoriumd}
KHORIUMCLI=${KHORIUMCLI:-$SRCDIR/khorium-cli}
KHORIUMTX=${KHORIUMTX:-$SRCDIR/khorium-tx}
KHORIUMQT=${KHORIUMQT:-$SRCDIR/qt/khorium-qt}

[ ! -x $KHORIUMD ] && echo "$KHORIUMD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
KHOVER=($($KHORIUMCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for khoriumd if --version-string is not set,
# but has different outcomes for khorium-qt and khorium-cli.
echo "[COPYRIGHT]" > footer.h2m
$KHORIUMD --version | sed -n '1!p' >> footer.h2m

for cmd in $KHORIUMD $KHORIUMCLI $KHORIUMTX $KHORIUMQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${KHOVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${KHOVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
