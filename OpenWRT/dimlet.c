//
//  dimlet.c
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
 * 'open_port()' - Open serial port 0.
 *
 * Returns the file descriptor on success or -1 on error.
 */

int
open_port(void)
{
    int fd; /* File descriptor for the port */
    struct termios options;

    fd = open("/dev/ttyS0", O_RDWR | O_NOCTTY | O_NDELAY);
    if (fd == -1)
    {
           /*
        * Could not open the port.
        */

        perror("open_port: Unable to open /dev/ttyS0 - ");
    } else
        fcntl(fd, F_SETFL, 0);

    
    /*
     * Get the current options for the port...
     */
    tcgetattr(fd, &options);

    /*
     * Set the baud rates to 19200...
     */
    cfsetispeed(&options, B38400);
    cfsetospeed(&options, B38400);

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
    struct sockaddr_in my_addr;    // my address information
    struct sockaddr_in their_addr; // connector's address information
    socklen_t addr_len;
    int numbytes;
    unsigned char buf[MAXBUFLEN];
    int fd;                         //file descriptor

    printf("Waiting for UDP command\n");  
      
    if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
        perror("socket");
        exit(1);
    }

    my_addr.sin_family = AF_INET;         // host byte order
    my_addr.sin_port = htons(MYPORT);     // short, network byte order
    my_addr.sin_addr.s_addr = INADDR_ANY; // automatically fill with my IP
    memset(my_addr.sin_zero, '\0', sizeof my_addr.sin_zero);

    if (bind(sockfd, (struct sockaddr *)&my_addr, sizeof my_addr) == -1) 
    {
        perror("bind");
        exit(1);
    }


    addr_len = sizeof their_addr;

    //Serial port code

	fd=open_port();
    
    while(1){    
    
        if ((numbytes = recvfrom(sockfd, buf, MAXBUFLEN-1 , 0,(struct sockaddr *)&their_addr, &addr_len)) == -1) {
            perror("Receive Error (recvfrom)");
            exit(1);
        }

        //printf("got packet from %s\n",inet_ntoa(their_addr.sin_addr));
        //printf("packet is %d bytes long\n",numbytes);
        //buf[numbytes] = '\0';
        //printf("packet contains \"%s\"\n",buf);   

        //forward the package out the serial port
        write(fd, buf, numbytes);
        
        printf("Command: %d %d %d %d %d\n",buf[0],buf[1],buf[2],buf[3],buf[4]);
    }
    
    close(sockfd);

    return 0;
}

