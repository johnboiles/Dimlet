# Hey Emacs, this is a -*- makefile -*-
#
# Author: John Boiles
# A super-simple makefile for compiling sources for the Fonera
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

TARGET = dimlet
SRC = $(TARGET).c

CC = /home/johnboiles/kamikaze-trunk/staging_dir/toolchain-mips_gcc4.1.2/bin/mips-linux-uclibc-gcc
SHARE = /home/johnboiles/public/

# Compiler flag to set the C Standard level.
# c89   - "ANSI" C
# gnu89 - c89 plus GCC extensions
# c99   - ISO C99 standard (not yet fully implemented)
# gnu99 - c99 plus GCC extensions
CSTANDARD = -std=gnu99

# Place -D or -U options here
CDEFS =

# Place -I options here
CINCS =

CFLAGS =$(CDEFS) $(CINCS) $(CSTANDARD)

REMOVE = rm -f
COPY = cp

all: target

target: $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC)

# Target: clean project.
clean:
	$(REMOVE) $(TARGET)

# Copy to shared folder
copy: all
	$(COPY) $(TARGET) $(SHARE)

install: all
	scp $(TARGET)  root@dimlet.local:/usr/bin/
