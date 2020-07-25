errim = [48, 210, 255, 241; 50, 193, 200, 203; ...
         54 198, 180, 172; 50, 208, 215, 180];
     
QStep = 0.6250;
QP = 1;

int_errim = IntTrafo4x4(errim, QP);
rec_errim = InvIntTrafo4x4(int_errim, QP);

     
errim == rec_errim     