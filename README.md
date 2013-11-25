# RubyValve

This gem provide a mechanism for doing easy flow type code pattern. Similar to what's done in 
the template design pattern.


## Installation

Add this line to your application's Gemfile:

    gem 'ruby_valve'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby_valve

## Usage


To use RubyValve you need to subclass the base class:

    class Foo < RubyValve::Base
    end
    
###step_n methods
Next you define a number steps using the naming convention of step_n for the method name.

    class Foo < RubyValve::Base
    
      def step_1
        puts "A"
      end
      
      def step_2
        puts "B"  
      end 
    end

After defining step_n methods you can execute then all by running the #execute method.

    Foo.new.execute
    
    A
    B

###skip
You can skip a step by using the skip method

    def step_1
      puts "A"
      skip :step_2, :step_3
    end
    
    def step_2
      puts "B"
    end
    
    def step_3
      puts "C"
    end
    
    def step_4
      puts "D"
    end        
    
    
    Foo.new.execute
    
    A
    D
    
###abort
You can have it abort at a certain step and it will not execute the remainder of the steps.

    def step_1
      puts "A"
    end
    
    def step_2
      abort "Ug, again?"
    end
    
    def step_3
      puts "C"
    end
    
    def step_4
      puts "D"
    end        
    
    
    Foo.new.execute
    
    A
    
You can also have abort raise an error as well.

    def step_1
      puts "A"
    end
    
    def step_2
      abort "Ug, again?", raise: true
    end
    
    def step_3
      puts "C"
    end
    
    def step_4
      puts "D"
    end        
    
    
    Foo.new.execute
    
    A
    RubyValve::AbortError: 
      Ug
      
####step_n_result
The result of each step_n method can be accessed by calling step_n_result. This allows the sharing of data between methods.

    def step_1
      "A"
    end
    
    def step_2
      puts "step 1's result was: #{step_1_result}"
    end
    
    Foo.new.execute
    
    step 1's result was: A
    
    
####response
The response for each step is recorded in a hash that can be accessed by this method

      def step_1
        "A"
      end
      
      def step_2
        "B"  
      end 

      foo = Foo.new
      foo.execute
      foo.result
      
      {:step_1_result=>"A", :step_2_result=>"B"}
        
        
###Callbacks
RubyValve provides a number of callbacks.

####before_all

Executes code once before all the steps.

    def before_all
      puts "..BA"
    end
    
    def step_1
      "A"
    end
      
    def step_2
      "B"  
    end     
    
    Foo.new.execute
    
    ..BA
    A
    B

####before_each
Executes code before each step method

    def before_each
      puts "..BE"
    end
    
    def step_1
      "A"
    end
      
    def step_2
      "B"  
    end      
    
    Foo.new.execute
    
    ..BE
    A
    ..BE
    B

####after_each
Executes code after each step method.

    def after_each
      puts "..AE"
    end

    def step_1
      "A"
    end
      
    def step_2
      "B"  
    end  
    
    Foo.new.execute
    
    A
    ..AE
    B
    ..AE    
    
####after_success
Executes if no abort was triggered or exceptions raised.

    def step_1
      puts "E"
    end
    
    def after_success
      puts "Yay!"
    end
    
    
    Foo.new.execute
    
    E
    Yay!
    
####after_abort
Executes if an abort, with a raise, was triggered.

    def step_1
      abort "call it off"
    end
    
    def step_2
      puts "E"
    end
    
    def after_abort
      puts "aborted!"
    end
    
    Foo.new.execute
    
    aborted!  

####after_raise and exeception
Creating an after_raise method will trigger an automatic rescue when an error is raised. The exception is stored in the **exception** method.

    def step_1
      abort "call it off", raise: true
    end
    
    def step_2
      puts "E"
    end
    
    def after_raise
      puts exception.message
    end
    
    Foo.new.execute
    
    call it off
    
###execution logs
There are a couple of methods that can be used to look at what was executed.

####executed_steps

This will display each step_n method that was actually executed.

    def step_1
      "A"
    end
    
    def step_2
      "B"
    end
    
    def after_each
      puts "..AE"
    end
    
    foo = Foo.new
    foo.execute
    foo.executed_steps
    
    [:step_1, :step_2]
    
####executed
This will display each step and callback method that was executed.

    def step_1
      "A"
    end
    
    def step_2
      "B"
    end
    
    def after_each
      puts "..AE"
    end
    
    foo = Foo.new
    foo.execute
    foo.executed_steps
    
    [:step_1, :after_each, :step_2, :after_each]
    
##Suggestions

I would recommend encapsulating the logic of what is to be done into methods with names that clearly state the intention of the code.

####Example

    def step_1
      post_paypal_transaction
    end
    
    def step_2
      store_paypal_result(step_1_result)
    end
    
    def step_3
      update_transaction_records
    end
    
    #=> ACTIONS
    def post_paypal_transaction
      #code
    end
    
    def store_paypal_result(paypal_results)
      #code
    end
    
    def post_paypal_transaction
      #code
    end       