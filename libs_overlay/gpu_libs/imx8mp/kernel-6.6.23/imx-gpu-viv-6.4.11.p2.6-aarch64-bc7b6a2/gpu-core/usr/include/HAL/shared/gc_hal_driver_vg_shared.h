/****************************************************************************
*
*    Copyright (c) 2005 - 2023 by Vivante Corp.  All rights reserved.
*
*    The material in this file is confidential and contains trade secrets
*    of Vivante Corporation. This is proprietary information owned by
*    Vivante Corporation. No part of this work may be disclosed,
*    reproduced, copied, transmitted, or used in any way for any purpose,
*    without the express written permission of Vivante Corporation.
*
*****************************************************************************/

/*
 * Interface specification between user and kernel level HAL layers.
 */

#ifndef __gc_hal_driver_vg_shared_h_
#define __gc_hal_driver_vg_shared_h_

#include "gc_hal_types.h"

#if defined(__QNXNTO__)
#include <sys/siginfo.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

/******************************************************************************
 ****************************** I/O Control Codes *****************************
 ******************************************************************************/

#define gcvHAL_CLASS            "galcore"
#define IOCTL_GCHAL_INTERFACE   30000

/******************************************************************************
 ******************** Command buffer information structure. *******************
 ******************************************************************************/

typedef struct _gcsCOMMAND_BUFFER_INFO *gcsCOMMAND_BUFFER_INFO_PTR;
typedef struct _gcsCOMMAND_BUFFER_INFO {
    /* FE command buffer interrupt ID. */
    gctINT32                    feBufferInt;

    /* TS overflow interrupt ID. */
    gctINT32                    tsOverflowInt;

    /* Alignment and mask for the buffer address. */
    gctUINT                     addressMask;
    gctUINT32                    addressAlignment;

    /* Alignment for each command. */
    gctUINT32                   commandAlignment;

    /* Number of bytes required by the STATE command. */
    gctUINT32                   stateCommandSize;

    /* Number of bytes required by the RESTART command. */
    gctUINT32                   restartCommandSize;

    /* Number of bytes required by the FETCH command. */
    gctUINT32                   fetchCommandSize;

    /* Number of bytes required by the CALL command. */
    gctUINT32                   callCommandSize;

    /* Number of bytes required by the RETURN command. */
    gctUINT32                   returnCommandSize;

    /* Number of bytes required by the EVENT command. */
    gctUINT32                   eventCommandSize;

    /* Number of bytes required by the END command. */
    gctUINT32                   endCommandSize;

    /* Number of bytes reserved at the tail of a static command buffer. */
    gctUINT32                   staticTailSize;

    /* Number of bytes reserved at the tail of a dynamic command buffer. */
    gctUINT32                   dynamicTailSize;
} gcsCOMMAND_BUFFER_INFO;

/******************************************************************************
 ******************************* Task Structures ******************************
 ******************************************************************************/

typedef struct _gcsTASK_HEADER *gcsTASK_HEADER_PTR;
typedef struct _gcsTASK_HEADER {
    /* Task ID. */
    IN gceTASK                  id;
} gcsTASK_HEADER;

typedef struct _gcsTASK_LINK *gcsTASK_LINK_PTR;
typedef struct _gcsTASK_LINK {
    /* Task ID (gcvTASK_LINK). */
    IN gceTASK                  id;

    /* Pointer to the next task container. */
    IN gctPOINTER               cotainer;

    /* Pointer to the next task from the next task container. */
    IN gcsTASK_HEADER_PTR       task;
} gcsTASK_LINK;

typedef struct _gcsTASK_CLUSTER *gcsTASK_CLUSTER_PTR;
typedef struct _gcsTASK_CLUSTER {
    /* Task ID (gcvTASK_CLUSTER). */
    IN gceTASK                  id;

    /* Number of tasks in the cluster. */
    IN gctUINT                  taskCount;
} gcsTASK_CLUSTER;

typedef struct _gcsTASK_INCREMENT *gcsTASK_INCREMENT_PTR;
typedef struct _gcsTASK_INCREMENT {
    /* Task ID (gcvTASK_INCREMENT). */
    IN gceTASK                  id;

    /* Address of the variable to increment. */
    IN gctUINT32                address;
} gcsTASK_INCREMENT;

typedef struct _gcsTASK_DECREMENT *gcsTASK_DECREMENT_PTR;
typedef struct _gcsTASK_DECREMENT {
    /* Task ID (gcvTASK_DECREMENT). */
    IN gceTASK                  id;

    /* Address of the variable to decrement. */
    IN gctUINT32                address;
} gcsTASK_DECREMENT;

typedef struct _gcsTASK_SIGNAL *gcsTASK_SIGNAL_PTR;
typedef struct _gcsTASK_SIGNAL {
    /* Task ID (gcvTASK_SIGNAL). */
    IN gceTASK                  id;

    /* Process owning the signal. */
    IN gctHANDLE                process;

    /* Signal handle to signal. */
    IN gctSIGNAL                signal;

#if defined(__QNXNTO__)
    IN struct sigevent          event;
    IN gctINT32                 rcvid;
#endif
} gcsTASK_SIGNAL;

typedef struct _gcsTASK_LOCKDOWN *gcsTASK_LOCKDOWN_PTR;
typedef struct _gcsTASK_LOCKDOWN {
    /* Task ID (gcvTASK_LOCKDOWN). */
    IN gceTASK                  id;

    /* Address of the user space counter. */
    IN gctUINT32                userCounter;

    /* Address of the kernel space counter. */
    IN gctUINT32                kernelCounter;

    /* Process owning the signal. */
    IN gctHANDLE                process;

    /* Signal handle to signal. */
    IN gctSIGNAL                signal;
} gcsTASK_LOCKDOWN;

typedef struct _gcsTASK_UNLOCK_VIDEO_MEMORY *gcsTASK_UNLOCK_VIDEO_MEMORY_PTR;
typedef struct _gcsTASK_UNLOCK_VIDEO_MEMORY {
    /* Task ID (gcvTASK_UNLOCK_VIDEO_MEMORY). */
    IN gceTASK                  id;

    /* Allocated video memory. */
    IN gctUINT64                node;
} gcsTASK_UNLOCK_VIDEO_MEMORY;

typedef struct _gcsTASK_FREE_VIDEO_MEMORY *gcsTASK_FREE_VIDEO_MEMORY_PTR;
typedef struct _gcsTASK_FREE_VIDEO_MEMORY {
    /* Task ID (gcvTASK_FREE_VIDEO_MEMORY). */
    IN gceTASK                  id;

    /* Allocated video memory. */
    IN gctUINT64                node;
} gcsTASK_FREE_VIDEO_MEMORY;

typedef struct _gcsTASK_FREE_CONTIGUOUS_MEMORY *gcsTASK_FREE_CONTIGUOUS_MEMORY_PTR;
typedef struct _gcsTASK_FREE_CONTIGUOUS_MEMORY {
    /* Task ID (gcvTASK_FREE_CONTIGUOUS_MEMORY). */
    IN gceTASK                  id;

    /* Number of bytes allocated. */
    IN gctSIZE_T                bytes;

    /* Physical address of allocation. */
    IN gctPHYS_ADDR             physical;

    /* Logical address of allocation. */
    IN gctPOINTER               logical;
} gcsTASK_FREE_CONTIGUOUS_MEMORY;

#ifdef __cplusplus
}
#endif

#endif /* __gc_hal_driver_shared_h_ */


