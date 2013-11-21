require 'ruby_valve/errors'

module RubyValve
  class Base
    attr_reader :executed_steps, :executed, :exception
    
    def init
      @skip_list = []
    end

    def execute
      init

      if respond_to?(:after_exception)
        begin
          execute_methods
        rescue => e
          @exception = e
          send(:after_exception)
        end
      else
        execute_methods
      end

    end

    def response
      @response
    end

    protected 

      def execute_methods
        # begin
        @response = {}
        
        if respond_to?(:before_all)
          send(:before_all) 
          log_execution(:before_all)
        end

        execution_order.each do |_method|
          if !self.skip?(_method)
          
            if respond_to?(:before_each)
              send(:before_each)    
              log_execution(:before_each)           
            end

            #create method to store step results
            self.class.class_eval {attr_accessor :"#{_method}_result"}
            result = send(_method)

            #assign step result information
            @response[:"#{_method}_result"] = result
            send(:"#{_method}_result=", result) 

            #log step exec
            log_step_execution(_method)

            if respond_to?(:after_each)    
              send(:after_each)        
              log_execution(:after_each)
            end
          end
        end

        if respond_to?(:after_success) && !abort_triggered?
          send(:after_success) 
          log_execution(:after_success)
        end

        if respond_to?(:after_abort) && abort_triggered?
          send(:after_abort)  
          log_execution(:after_abort)
        end        
      end

      #=> logging methods
      def log_step_execution(_method)
        (@executed_steps ||= []) << _method
        log_execution(_method)
      end

      def log_execution(_method)
        (@executed ||= []) << _method
      end

      def abort(message, options = {})
        @abort_triggered = true
        @abort_message = message 
        raise(AbortError, @abort_message) if options[:raise]
      end

      #=> skip methods
      def skip_all_steps?
        abort_triggered?
      end

      def skip(*step_names)
        skip_list.push *step_names
      end

      def skip_list
        @skip_list
      end

      def abort_triggered?
        @abort_triggered
      end

      def skip?(method_name)
        return true if skip_all_steps?

        skip_list.include?(method_name)
      end
    
      def execution_order
        step_methods = methods.select {|meth| meth.to_s.match(/^step_[0-9]*$/)}

        step_methods.sort do |x,y|
          ordinal_x = x.to_s.split("_").last.to_i
          ordinal_y = y.to_s.split("_").last.to_i

          ordinal_x <=> ordinal_y
        end
      end

  end  
end