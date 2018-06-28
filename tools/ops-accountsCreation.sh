#!/bin/bash

# Simple script for adding OPS user groups, accounts and ssh keys to a local system

users=("lucafuso" "rzeznik" "michaelwe" "lundsten" "tovukman" "tsschuel")
ids=("1001" "1002" "1003" "1004" "1005" "1006")

# get the length of the arrays
length=${#users[@]}

# Create groups and users
for ((i=0;i<$length;i++)); do

        echo "Creating group:    " "${users[$i]}" "with group id" "${ids[$i]}"
	groupadd -g "${ids[$i]}" "${users[$i]}"

        echo "Creating user:     " "${users[$i]}" "with user id" "${ids[$i]}" "belonging to the wheels group"
	adduser -g "${ids[$i]}" -G 10 -u "${ids[$i]}" "${users[$i]}"

        echo "Creating .ssh dirs:" "/home/${users[$i]}/.ssh"
        mkdir /home/"${users[$i]}"/.ssh
	chown "${users[$i]}":"${users[$i]}" /home/"${users[$i]}"/.ssh

done


# Set up SSH keys

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/5SCcuVMAeZZ4QXlUgNUkS/nEIgeU41dlFqc7Pgbnjoal6L5SgrLftWHrpXdAUwpK/qilRCtNZs2VCaBJ51jkJtjSZqd75E9g41Ttf7Q8tiz4UYmIm/ABdMZIMkLTVvci50gioSON5+I1y/WceJE1kKE1rYTaSh8sFEBwTfgg8iDruYLslifzodHBDOowKtZgNQFepZRJMHGRPJKF1Jr664VIYUB+5BPa8PDtM4Gf0+JcQJXyknqLC9nQQMOaH6+GYnZiAPoqD5No5Q5eDwqW7c15DB8CPtxS2ZuiDNYhFW6jgomKxvdAUqp3AJoXaNZP9xPbjwQBNCOw5v/L7RsL lucafuso@everything" > /home/lucafuso/.ssh/authorized_keys
chown lucafuso:lucafuso /home/lucafuso/.ssh/authorized_keys

echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAw6K/nI8uIhcynZSNJvSA7EUu0HrBkhNHALF/2IohFB7LisnZqypsC7uhOurruChdPFKmSkhrno6YH/s2KLI4oodmBFh8HBjIOWWCjQh2TM3k7f14EbHzhZA+Qn1YRqLMzDBA7+55vdrrvjhWRyjQQKdq5Rs6ePURGdHDXED4BeB5JxIjeBDERo467dNw4+p3j5vVNYKgy+UnMFx5zM7mL+nE+LbC2mgMw+o3gzcNe2cDJ8Qss6o2zwOH3JF92T5+HVQGcOz+ewgf9Cqp/Pnmrreu3c+jl0NVGvphbUdXnVBTM0qIBXESHZX+JwpogqcHAQ7vAfbNi5rz2nn68cBafw== jrze@localhost.localdomain" > /home/rzeznik/.ssh/authorized_keys
chown rzeznik:rzeznik /home/rzeznik/.ssh/authorized_keys

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDH7hXexF42G+JF0wTIiqPGXLoVFlIg5gJdO983R022GyjTG+Y31JyBee7zRkSP8ive659kO1M4yl8ftq5Z3vCqhO+B2AeeyYrzUGMUVvj3cYOanuXsnVy1EiLMwMsvISbjwDTmY2yD0DoptYfLxugmzmcdmADAaM86KCwWmYuLiy5pzAMHZqoMy8MT7WeI1o/8i2sXnYoBBFFmTwKoxg2T+Cu2xQwTcSb0sh1sN5+vHEFGcec34S2bQZ3xKvAWNX/+UiFV/7KUWK4OYP/LBiBg3aQNnea8vgr9tm9gaZjTlsleMCJQcy4Jk05waN64MZ5GrVYbSJQ9MAZKdPRaffYL michaelwelsing@Michaels-MacBook-Pro.local" > /home/michaelwe/.ssh/authorized_keys
chown michaelwe:michaelwe /home/michaelwe/.ssh/authorized_keys

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCkl7v9eedvBCOO60auzSIj+vPl/1qaRHU2LPYX8LxpiFEkFjQCKLQHBiTPRp9xE3wPuO7AMilDQRQDIUBgykPBWmQt7t3AiRD0qOtAsXPf6C6VJ2qABxKDWZvdtsvzoXkOvay98XjNoXmoImeiw0sKK2RlPUNIpTz+N04hyeu6TjLP/jaEitjZoi2QG635I50Y4gAhyk+Oh22oDiKS0AAxgpoSeFDH5Ua1VPdmeyhTamOhmfrIplZX5jcsLo99SNycR4CdS3ags1e2b8e0KBp1XNeC6ZTHNF3YteUJazAARDILjdSS5o8oXplr3fiAYSuAWp0T7JrYiiaF2McoAwE5 alflundsten@Alfs-MacBook-Pro.local" > /home/lundsten/.ssh/authorized_keys
chown lundsten:lundsten /home/lundsten/.ssh/authorized_keys

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+lhwjC/Tt8eMILXT5cEcyYOTL9NdLxizDGqmeLtVS5TAhKTjqwkKPMmcRX+tlCacJ8u3KdpZCriFGh2tQxpZZhn21T7sFk/b3g3Gal81jGdKDVRhB1Tefoq9JPS3v5YFrj2e6iNGJqUTGpWJJqHtFlXRhsVDMnD9PJ4PIkZypCK+qVuZWiKilS4q5DYKbIDDy2JfvqtZpnNvRrIwnywdqYxRojAqlFcHWPFi/NNbVIZkfV6xhGS8FastbOLWcLuMfqOnrTQw6FdvgVO/NOJfdQ9n+/eN63I7rVBmOmu5yWTsPn3jTrCKnvbPqykh0iUl/X1m5EHASoaxFYImmtT0T tovukman@tovukman-XPS-13-9360" > /home/tovukman/.ssh/authorized_keys
chown tovukman:tovukman /home/tovukman/.ssh/authorized_keys

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDf27KTGNOs+tPp6xMPeNtk7jBXUvK9I0eQjOuJlH/PdpFEJfPxaojjZcaVP7vWiN3z5MFinq7sh6/CnKpYhHsJGUqIz1PHcrCNQK5JRIEtm93rZNTd7kx+iuyfjTcDWwVDlCoTUesTvPN3V1/B+F7rKSIrVjEyE/a0jSveM5pVe+K864iX6PDIHj5eteyQsBcues7BsKFn+TIdM937018Y/QoWsJVXN5a7mfLllhJw2rpE3cpTChj+pj2+RC19cgJCsgfj5xzeXp8bRWXStUFIUDpap/Fr+8g9jJ5Vblg0M+jG2Jx8uhYCKht3qSXSihciXdcEfaOxA+SPS2/5hSaR" > /home/tsschuel/.ssh/authorized_keys
chown tsschuel:tsschuel /home/tsschuel/.ssh/authorized_keys

cd /home
find . -name authorized_keys -exec chmod 0600 {} \;
find . -type d -name .ssh -exec chmod 0700 {} \;


# Sudoers
chmod 0660 /etc/sudoers
sed -i '/"# %wheel/c\%wheel        ALL=(ALL)       NOPASSWD: ALL' /etc/sudoers
chmod 0440

