# ProiectPracticaAnul2
Acesta este proiectul pentru practica din anul 2.  
Tema proiect: Monitorizare fișiere dintr-un director folosind inotify-tools  
Extplicatie:  
-fisierul script.sh verifica toate instructiunile exitstente in inotify-tools si salveaza datele atat intr-un fisier cat si intr-o baza de date creata cu SQLite.  
-fisierul interfata.py genereaza o interfata grafica in care cu ajutorul bazei de date, a unor campuri de inserare de date si a unor butoane cauta se pot filtra evenimentele, fie doar dupa numele fisierului, fie doar dupa tipul de eveniment, fie dupa amandoua. Cu  butonul "Filter" se filtreaza evenimentele, cu butonul "Refresh" se afiseaza toate evenimentele pana in momentul curent, iar cu butonul "Clear Events" se sterg toate evenimentele din interfata (nu si din baza de date). In cazul in care este inserat un fisier sau un eveniment care nu se regaseste in baza de date campul aferent se coloreaza cu rosu pentru a indica acest fapt.