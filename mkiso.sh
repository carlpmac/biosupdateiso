mkisofs -o ../biosupdate.iso -q -l -N \
   -boot-info-table -iso-level 4 -no-emul-boot \
   -b isolinux/isolinux.bin \
   -publisher "https://github.com/carlpmac/biosupdateiso/" \
   -A "BIOS Update ISO" -V FDBIOSUP -v .
