#!/bin/bash

sudo mysql -phitman << EOF
use books;
select * from authors;
EOF

