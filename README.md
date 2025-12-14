# ☕ Komkom - כלי הקומקום לשורת הפקודה

כלי מעליזי לשורת הפקודה שמסמיל תהליך הכנת קפה עם אנימציות ASCII ומעקב מצב.

## 🚀 התקנה

### דרישות מוקדמות
- מערכת Unix/Linux/macOS
- Python 3
- הרשאות sudo

### התקנה
```bash
git clone https://github.com/Mocoloco461/komkom
chmod +x install.sh
./install.sh
```

אם הכלי לא מזוהה, הוסיפו ל-`~/.bashrc`:
```bash
export PATH="/usr/local/bin:$PATH"
source ~/.bashrc
```

## 📖 פקודות

### פקודות בסיסיות
```bash
komkom pull water    # מילוי מים
komkom boil          # הרתחה  
komkom pour mug      # יציקה (cup/mug/thermos)
komkom sip          # לגימה + ציטוט
komkom status       # מצב נוכחי
komkom empty        # ריקון
komkom help         # עזרה
```

## 🗑️ הסרת התקנה

למחיקת הכלי מהמחשב:
```bash
chmod +x uninstall.sh
./uninstall.sh
```

### תהליך מלא
```bash
komkom pull water
komkom boil
komkom pour mug
komkom sip
```

## 🎯 מאפיינים

- **אנימציות ASCII** - מילוי, הרתחה, יציקה
- **מעקב מצב** - מפלס מים, טמפרטורה, כוסות יומיות
- **מצבי רוח** - waiting, ready, excited, satisfied, zen, empty
- **ציטוטים** - מעוררי השראה עם כל לגימה
- **מצב מתמשך** - נשמר ב-`~/.komkom/state.json`

---

☕ **תהנו מהקפה הווירטואלי!**
