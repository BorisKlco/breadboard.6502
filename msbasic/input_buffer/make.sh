if [ ! -d tmp ]; then
	mkdir tmp
fi

for i in w65c02; do

echo $i
ca65 -D $i msbasic.s -o tmp/$i.o &&
ld65 -C $i.cfg tmp/$i.o -o tmp/$i.bin -Ln tmp/$i.lbl

done


C:\Users\klco\Downloads\cc65\bin\ca65.exe -D w65c02 msbasic.s -o w65c02.o
C:\Users\klco\Downloads\cc65\bin\ld65.exe -C w65c02.cfg w65c02.o -o w65c02.bin -Ln w65c02.lbl