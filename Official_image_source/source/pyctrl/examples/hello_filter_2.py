#!/usr/bin/env python3

def main():

    import sys
    
    # import Controller and other blocks from modules
    from pyctrl.timer import Controller
    from pyctrl.block import Interp, Printer, Constant, Logger

    # initialize controller
    Ts = 0.01
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
    
    # add logger
    hello.add_sink('logger',
                   Logger(),
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

    # retrieve data from logger
    data = hello.get_sink('logger', 'log')
    
    try:

        # import matplotlib
        import matplotlib.pyplot as plt

    except:

        print('! Could not load matplotlib, skipping plots')
        sys.exit(0)

    print('> Will plot')
        
    try:
        
        # start plot
        plt.figure()

    except:

        print('! Could not plot graphics')
        print('> Make sure you have a connection to a windows manager')
        sys.exit(0)
        
    # plot input 
    plt.plot(data['clock'], data['motor'], 'b')
    plt.ylabel('pwm (%)')
    plt.xlabel('time (s)')
    plt.ylim((-120,120))
    plt.xlim(0,6)
    plt.grid()
    
    # show plots
    plt.show()

if __name__ == "__main__":
    
    main()
