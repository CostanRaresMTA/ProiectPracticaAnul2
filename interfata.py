import tkinter as tk
from tkinter import ttk, messagebox
import sqlite3

#Conectarea la baza de date SQLite
conn = sqlite3.connect('inotify_events.db')
cursor = conn.cursor()

#Crearea ferestrei principale
root = tk.Tk()
root.title("Inotify Events Database")

#Functia pentru a filtra rezultatele in tabel
def filter_events():
    file_filter = entry_search_filename.get().strip()
    event_filter = entry_search_event.get().strip()

    query = "SELECT * FROM Events WHERE 1=1"
    params = []
    if file_filter:
        query += " AND FileName LIKE ?"
        params.append(f"%{file_filter}%")
    if event_filter:
        query += " AND Event LIKE ?"
        params.append(f"%{event_filter}%")

    for row in tree.get_children():
        tree.delete(row)
    cursor.execute(query, params)
    results = cursor.fetchall()

    if not results:
        messagebox.showinfo("No Results", "No matching records found.")
        if file_filter and not event_filter:
            entry_search_filename.config(bg='lightcoral')
        elif event_filter and not file_filter:
            entry_search_event.config(bg='lightcoral')
        elif file_filter and event_filter:
            entry_search_filename.config(bg='lightcoral')
            entry_search_event.config(bg='lightcoral')
    else:
        entry_search_filename.config(bg='white')
        entry_search_event.config(bg='white')
        for row in results:
            tree.insert("", "end", values=row)

#Functia pentru a reimprospata tabelul
def refresh_table():
    for row in tree.get_children():
        tree.delete(row)
    cursor.execute("SELECT * FROM Events")
    for row in cursor.fetchall():
        tree.insert("", "end", values=row)

#Functia pentru a curata vizual tabelul din interfata
def clear_events():
    for row in tree.get_children():
        tree.delete(row)
    entry_search_filename.delete(0, tk.END)
    entry_search_event.delete(0, tk.END)
    messagebox.showinfo("Events Cleared", "All events have been cleared from the display.")

#Crearea cadrului pentru filtrare
frame_filter = ttk.Frame(root)
frame_filter.pack(pady=10)

ttk.Label(frame_filter, text="Search File Name:").grid(row=0, column=0, padx=5)
entry_search_filename = tk.Entry(frame_filter)
entry_search_filename.grid(row=0, column=1, padx=5)

ttk.Label(frame_filter, text="Search Event:").grid(row=1, column=0, padx=5)
entry_search_event = tk.Entry(frame_filter)
entry_search_event.grid(row=1, column=1, padx=5)

ttk.Button(frame_filter, text="Filter", command=filter_events).grid(row=2, column=0, columnspan=2, pady=10)

#Crearea cadrului pentru butoane
frame_buttons = ttk.Frame(root)
frame_buttons.pack(pady=10)

ttk.Button(frame_buttons, text="Refresh", command=refresh_table).pack(side=tk.LEFT, padx=5)
ttk.Button(frame_buttons, text="Clear Events", command=clear_events).pack(side=tk.LEFT, padx=5)

#Crearea cadrului pentru tabel
frame_table = ttk.Frame(root)
frame_table.pack(pady=10)

#Crearea tabelului
columns = ("ID", "FileName", "Event", "EventTime")
tree = ttk.Treeview(frame_table, columns=columns, show="headings")
for col in columns:
    tree.heading(col, text=col)
tree.pack()

#Actualizarea tabelului la lansarea aplicatiei
refresh_table()

#Rularea aplicatiei
root.mainloop()

#Inchiderea conexiunii la baza de date
conn.close()
