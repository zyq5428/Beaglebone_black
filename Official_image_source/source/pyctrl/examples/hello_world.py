#!/usr/bin/env python3

def main():

    # import python's standard time module
    import time

    # import Controller and other blocks from modules
    from pyctrl import Controller
    from pyctrl.block import Printer
    from pyctrl.block.clock import TimerClock

    # initialize controller
    hello = Controller()

    # add the signal myclock
    hello.add_signal('myclock')

    # add a TimerClock as a source
    hello.add_source('myclock',
                     TimerClock(period = 1),
                     ['myclock'],
                     enable = True)

    # add a Printer as a sink
    hello.add_sink('message',
                   Printer(message = 'Hello World!'),
                   ['myclock'],
                   enable = True)

    try:
        # run the controller
        with hello:
            # do nothing for 5 seconds
            time.sleep(5)

    except KeyboardInterrupt:
        pass

    finally:
        print('Done')
    
if __name__ == "__main__":
    
    main()
