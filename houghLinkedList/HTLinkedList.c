#include <stdio.h>

#define SIZE 10
int nextIndex = 0;
struct LinkedList {
    int rho;
    int vote;
    int next;
} u1 [SIZE];

void append_as_array(int rho, int *addr, int *append_o, int *done_o) {
    int param_addr = 1;
    struct LinkedList t = u1[param_addr];
    for(param_addr=1; param_addr<SIZE; ++param_addr) {
        if(u1[param_addr].rho == rho) {
            u1[param_addr].vote += 1;
            *addr = param_addr;
            *append_o = 1;
            *done_o = 1;
            return;
        }
        else if(u1[param_addr].next == 0) {
            if(nextIndex < SIZE) {
                u1[param_addr].rho = rho;
                u1[param_addr].vote = 1;
                u1[param_addr].next = ++nextIndex;
                *addr = param_addr;
                *append_o = 1;
                *done_o = 1;
                return;
            }
            else {
                *append_o = 0;
                *done_o = 1;
                return; 
            }
        }
    }
}

void append_as_linkedlist(int rho, int *addr, int *append_o, int *done_o) {
    int param_addr = 0;
    
    while(u1[param_addr].next != 0) {
        param_addr = u1[param_addr].next;
        if(u1[param_addr].rho == rho) {
            u1[param_addr].vote += 1;
            *append_o = 1;
            return;
        }
    }
    
    if(nextIndex+1 < SIZE) {
        u1[param_addr].next = nextIndex+1;
        u1[nextIndex+1].rho = rho;
        u1[nextIndex+1].vote = 1;
        nextIndex = nextIndex+1;
        *append_o = 1;
    } else {
        *append_o = 0;
    }
}

void search(int rho, int *addr, int *found_o, int *done_o) {
    int param_addr = 0;
    while(u1[param_addr].next != 0) {
        param_addr = u1[param_addr].next;
        if(u1[param_addr].rho == rho) {
            *done_o = 1;
            *found_o = 1;
            *addr = param_addr;
            return;
        }
    }
    *done_o = 0;
    *found_o = 0;
    *addr = param_addr;
}

void append(int rho, int *addr, int *append_o, int *done_o) {
    //append_as_array(rho, addr, append_o, done_o);
    append_as_linkedlist(rho, addr, append_o, done_o);
}


int main(void) {
    int addr = 0;
    int append_o = 0;
    int done_o = 0;
    int found_o = 0;

    append(123, &addr, &append_o, &done_o);
    printf("addr:%d append_o:%d done_o:%d {rho:%d, vote:%d, next:%d}\n", addr, append_o, done_o, u1[addr].rho, u1[addr].vote, u1[addr].next);
    
    for(addr=0; addr<SIZE; ++addr) {
        printf("u1[%d]={rho:%d, vote:%d, next:%d}\n", addr, u1[addr].rho, u1[addr].vote, u1[addr].next);
    }
    
    append(123, &addr, &append_o, &done_o);
    printf("addr:%d append_o:%d done_o:%d {rho:%d, vote:%d, next:%d}\n", addr, append_o, done_o, u1[addr].rho, u1[addr].vote, u1[addr].next);
    
    for(addr=0; addr<SIZE; ++addr) {
        printf("u1[%d]={rho:%d, vote:%d, next:%d}\n", addr, u1[addr].rho, u1[addr].vote, u1[addr].next);
    }

    return 0;
    
    append(321, &addr, &append_o, &done_o);
    printf("addr:%d append_o:%d done_o:%d {rho:%d, vote:%d, next:%d}\n", addr, append_o, done_o, u1[addr].rho, u1[addr].vote, u1[addr].next);
    append(123, &addr, &append_o, &done_o);
    printf("addr:%d append_o:%d done_o:%d {rho:%d, vote:%d, next:%d}\n", addr, append_o, done_o, u1[addr].rho, u1[addr].vote, u1[addr].next);
    append(321, &addr, &append_o, &done_o);
    printf("addr:%d append_o:%d done_o:%d {rho:%d, vote:%d, next:%d}\n", addr, append_o, done_o, u1[addr].rho, u1[addr].vote, u1[addr].next);
    for(int i=0; i<SIZE+3; ++i) {
        append(i, &addr, &append_o, &done_o);
        if(!append_o) {
            printf("index %d > 4095\n", i);
        }
    }
    printf("---\n");
    for(int i=SIZE+3; i>=0; --i) {
        append(i, &addr, &append_o, &done_o);
        if(!append_o) {
            printf("index %d > 4095\n", i);
        }
    }

    printf("--------\n");
    for(addr=0; addr<SIZE; ++addr) {
        printf("u1[%d]={rho:%d, vote:%d, next:%d}\n", addr, u1[addr].rho, u1[addr].vote, u1[addr].next);
    }

    search(789, &addr, &found_o, &done_o);
    printf("found:%d, u1[%d]={rho:%d, vote:%d, next:%d}\n", found_o, addr, u1[addr].rho, u1[addr].vote, u1[addr].next);
    search(321, &addr, &found_o, &done_o);
    printf("found:%d, u1[%d]={rho:%d, vote:%d, next:%d}\n", found_o, addr, u1[addr].rho, u1[addr].vote, u1[addr].next);
    search(123, &addr, &found_o, &done_o);
    printf("found:%d, u1[%d]={rho:%d, vote:%d, next:%d}\n", found_o, addr, u1[addr].rho, u1[addr].vote, u1[addr].next);

    return 0;
}