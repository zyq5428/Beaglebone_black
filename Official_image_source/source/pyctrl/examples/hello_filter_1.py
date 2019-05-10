#!/usr/bin/env python3

def main():

    # import Controller and other blocks from modules
    from pyctrl.timer import Controller
    from pyctrl.block import Interp, Constant, Printer

    # initialize controller
    Ts = 0.1
    hello = Controller(period = Ts)

    # add pwm signal
    hello.add_signal('pwm')

    # build interpolated input signal
    ts = [0, 1, 2,   3,   4,   5,   5, 6]
    us = [0, 0, 100, 100, -50, -50, 0, 0]
    
    # add filter to interpolate data
    hello.add_filter('input',
		     Interp(xp = us, fp = ts),
		     ['clock'],
                     ['pwm'])

    # add logger
    hello.add_sink('printer',
                   Printer(message = 'time = {:3.1f} s, motor = {:+6.1f} %',
                           endln = '\r'),
                   ['clock','pwm'])

    # Add a timer to stop the controller
    hello.add_timer('stop',
		    Constant(value = 0),
		    None, ['is_running'],
                    period = 6, repeat = False)
    
    # print controller info
    print(hello.info('all'))
    
    try:

        # run the controller
        print('> Run the controller.')
        with hello:

            # wait for the controller to finish on its own
            hello.join()
            
        print('> Done with the controller.')
        
    except KeyboardInterrupt:
        pass

if __name__ == "__main__":
    
    main()
