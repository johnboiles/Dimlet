//
//  serial_test.c
//  Dimlet
//
//  Created by John Boiles on 7/23/09.
//  Copyright 2009 John Boiles. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>


#define MYPORT 4950    // the port users will be connecting to

#define MAXBUFLEN 100

#include <unistd.h>  /* UNIX standard function definitions */
#include <fcntl.h>   /* File control definitions */
#include <errno.h>   /* Error number definitions */
#include <termios.h> /* POSIX terminal control definitions */

/*
 * 'open_port()' - Open serial port 1.
 *
 * Returns the file descriptor on success or -1 on error.
 */

int
open_port(void)
{
    int fd; /* File descriptor for the port */
    struct termios options;

    fd = open("/dev/tts/0", O_RDWR | O_NOCTTY | O_NDELAY);
    if (fd == -1)
    {
           /*
        * Could not open the port.
        */

        perror("open_port: Unable to open /dev/tts/0 - ");
    } else
        fcntl(fd, F_SETFL, 0);

    
    /*
     * Get the current options for the port...
     */
    tcgetattr(fd, &options);

    /*
     * Set the baud rates to 19200...
     */
    cfsetispeed(&options, B9600);
    cfsetospeed(&options, B9600);

    /*
     * Enable the receiver and set local mode...
     */

    options.c_cflag |= (CLOCAL | CREAD);

    /*
     * Set the new options for the port...
     */

    tcsetattr(fd, TCSANOW, &options);


    return (fd);
}



int main(void)
{
    int sockfd;
    int fd;	
char a=0;
char b=70;
char c=150;
char d=255;


    printf("\nSerial Port Test: Sending this message out the serial port...\n");  
	      
    //Serial port code

    fd=open_port();

while(1){
sleep(1);
    write(fd,&a,1);    
    write(fd,&a,1);    
    write(fd,&b,1);    
    write(fd,&c,1);    
    write(fd,&d,1);    
sleep(1);
    write(fd,&a,1);    
    write(fd,&b,1);    
    write(fd,&c,1);    
    write(fd,&d,1);    
    write(fd,&a,1);    

sleep(1);
    write(fd,&a,1);    
    write(fd,&c,1);    
    write(fd,&d,1);    
    write(fd,&a,1);    
    write(fd,&b,1);    

sleep(1);
    write(fd,&a,1);    
    write(fd,&d,1);    
    write(fd,&a,1);    
    write(fd,&b,1);    
    write(fd,&c,1);    

}
    return 0;
}

