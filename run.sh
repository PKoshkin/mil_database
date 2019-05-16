sudo psql -U postgres -d test -f main.sql
python create_random_battlefield.py
sudo psql -U postgres -d test -f create_battlefield.sql
sudo psql -U postgres -d test -f print.sql
rm create_battlefield.sql
