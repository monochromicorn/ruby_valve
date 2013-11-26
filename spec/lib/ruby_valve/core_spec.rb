require 'spec_helper'

describe RubyValve::Base do
  describe "#execute" do
    before(:each) do
      class DummyValve 
        include RubyValve::Core
        define_method(:step_1) {}
        define_method(:step_2) {}
        define_method(:step_3) {}
      end

      @valve = DummyValve.new
    end

    it "should execute all step methods in order" do
      @valve.execute
      @valve.executed_steps.should eql([:step_1, :step_2, :step_3])
    end    

    it "should not execute steps after an abort" do
      def @valve.step_0
        abort "Ug, I give up"
      end

      @valve.execute
      @valve.executed_steps.should eql([:step_0])      
    end
  end

  describe "#skip" do
    before(:each) do

      class SkipValve 
        include RubyValve::Core 
        define_method(:step_1) {skip :step_2}
        define_method(:step_2) {}
        define_method(:step_3) {skip :step_4, :step_5}
        define_method(:step_4) {}
        define_method(:step_5) {}
      end 

      @skip_valve = SkipValve.new
    end

    it "should not execute skipped steps" do
      @skip_valve.execute
      @skip_valve.executed_steps.should eql([:step_1, :step_3])  
    end
  end

  describe "#response" do
    before(:each) do

      class Res  
        include RubyValve::Core

        define_method(:step_1) {"apple"}
        define_method(:step_2) {"banana"}
      end 

      @res = Res.new
    end    

    it "should contain the method results" do
      @res.execute
      @res.response.should eql({:step_1_result=>"apple", :step_2_result=>"banana"})
    end
  end

  describe "#step_x_result" do
    before(:each) do

      class Res1 
        include RubyValve::Core

        define_method(:step_1) {"apple"}
        define_method(:step_2) {"banana"}
      end 

      @res1 = Res1.new
    end     

    it "should equal the result of #step_x" do
      @res1.execute
      @res1.step_1_result.should eql "apple"
      @res1.step_2_result.should eql "banana"
    end
  end

  describe "#abort" do
    before(:each) do

      class AfterAbort 
        include RubyValve::Core

        define_method(:after_abort) {}
        define_method(:step_1) {skip :step_2}
        define_method(:step_2) {}
        define_method(:step_3) {abort "Ug", :raise => true}
        define_method(:step_4) {}
        define_method(:step_5) {}
      end 
    
      @after_abort = AfterAbort.new
    end   
    
    it "should raise AbortError when :raise => true" do
      expect {@after_abort.execute}.to raise_error(RubyValve::AbortError, "Ug")
    end
  end  

  #==> BEFORE HOOKS
  describe "#before_each" do
    before(:each) do

      class BeforeEach 
        include RubyValve::Core

        define_method(:before_each) {}
        define_method(:step_1) {skip :step_2}
        define_method(:step_2) {}
        define_method(:step_3) {skip :step_4, :step_5}
        define_method(:step_4) {}
        define_method(:step_5) {}
      end 
    
      @before_each = BeforeEach.new
    end

    it "should execute when defined" do
      @before_each.should_receive(:before_each).exactly(2)
      @before_each.execute 
    end

    it "should execute before each step_x" do
      @before_each.execute
      @before_each.executed.should eql([:before_each, :step_1, :before_each, :step_3])
    end      

    it "should not show up in executed_steps" do
      @before_each.execute
      @before_each.executed_steps.should eql([:step_1, :step_3])  
    end

  end  

  describe "#before_all" do
    before(:each) do

      class BeforeAll
        include RubyValve::Core
        define_method(:before_all) {}
        define_method(:step_1) {skip :step_2}
        define_method(:step_2) {}
        define_method(:step_3) {skip :step_4, :step_5}
        define_method(:step_4) {}
        define_method(:step_5) {}
      end 

      @before_all = BeforeAll.new
    end

    it "should execute when defined" do
      @before_all.should_receive(:before_all).exactly(1)
      @before_all.execute 
    end

    it "should execute before all steps" do
      @before_all.execute
      @before_all.executed.should eql([:before_all, :step_1, :step_3])
    end    

    it "should not show up in executed_steps" do
      @before_all.execute
      @before_all.executed_steps.should eql([:step_1, :step_3])  
    end

  end    

  #==> AFTER HOOKS
  describe "#after_each" do
    before(:each) do

      class AfterEach 
        include RubyValve::Core

        define_method(:after_each) {}
        define_method(:step_1) {skip :step_2}
        define_method(:step_2) {}
        define_method(:step_3) {skip :step_4, :step_5}
        define_method(:step_4) {}
        define_method(:step_5) {}
      end 
    
      @after_each = AfterEach.new
    end

    it "should execute when defined" do
      @after_each.should_receive(:after_each).exactly(2)
      @after_each.execute 
    end

    it "should execute after each step_x" do
      @after_each.execute
      @after_each.executed.should eql([:step_1, :after_each, :step_3, :after_each])
    end

    it "should not show up in executed_steps" do
      @after_each.execute
      @after_each.executed_steps.should eql([:step_1, :step_3])  
    end

  end  

  describe "#after_success" do
    before(:each) do

      class AfterSuccess 
        include RubyValve::Core

        define_method(:after_success) {}
        define_method(:step_1) {skip :step_2}
        define_method(:step_2) {}
        define_method(:step_3) {skip :step_4, :step_5}
        define_method(:step_4) {}
        define_method(:step_5) {}
      end 
    
      @after_success = AfterSuccess.new
    end

    context "when no abort is triggered" do

      it "should execute when defined" do
        @after_success.should_receive(:after_success).exactly(1)
        @after_success.execute 
      end

      it "should execute after all steps" do
        @after_success.execute
        @after_success.executed.should eql([:step_1, :step_3, :after_success])
      end

      it "should not execute after an abort" do
        def @after_success.step_1
          abort "Ug"
        end

        @after_success.execute
        @after_success.executed.should eql([:step_1])      
      end

      it "should not show up in executed_steps" do
        @after_success.execute
        @after_success.executed_steps.should eql([:step_1, :step_3])  
      end

    end

    context "when an abort is triggered" do
      it "should not execute when defined" do
        def @after_success.step_1
          abort "Ug"
        end

        @after_success.should_receive(:after_success).exactly(0)
        @after_success.execute 
      end      
    end
  end    

  describe "#after_abort" do
    context "after an abort is triggered" do
      before(:each) do

        class AfterAbortTest 
          include RubyValve::Core

          define_method(:after_abort) {}
          define_method(:step_1) {skip :step_2}
          define_method(:step_2) {}
          define_method(:step_3) {abort "Ug"}
          define_method(:step_4) {}
          define_method(:step_5) {}
        end 
      
        @after_abort = AfterAbortTest.new
      end

      it "should execute when defined" do
        @after_abort.should_receive(:after_abort).exactly(1)
        @after_abort.execute 
      end

      it "should execute after all the steps" do
        @after_abort.execute
        @after_abort.executed.should eql([:step_1, :step_3, :after_abort])        
      end

      it "should not execute steps after an abort" do
        @after_abort.execute
        @after_abort.executed_steps.should eql([:step_1, :step_3])      
      end

      it "should not show up in executed_steps" do
        @after_abort.execute
        @after_abort.executed_steps.should eql([:step_1, :step_3])  
      end

    end  
  end

  describe "#after_exception" do
    before(:each) do

      class AfterRaise 
        include RubyValve::Core

        define_method(:after_exception) {}
        define_method(:step_1) {skip :step_2}
        define_method(:step_2) {}
        define_method(:step_3) {abort "Ug", :raise => true}
        define_method(:step_4) {}
        define_method(:step_5) {}

      end 
    
      @after_raise = AfterRaise.new
    end   
        
    it "should not raise AbortError when :raise => true" do
      expect {@after_raise.execute}.to_not raise_error
    end    

  end

  describe "#exception" do
    before(:each) do

      class ExceptionTest 
        include RubyValve::Core

        define_method(:after_exception) {}
        define_method(:step_1) {skip :step_2}
        define_method(:step_2) {}
        define_method(:step_3) {abort "Ug", :raise => true}
        define_method(:step_4) {}
        define_method(:step_5) {}

      end 
    
      @after_raise = ExceptionTest.new
    end   
    
    it "should contain the raised exception" do
      @after_raise.execute
      @after_raise.exception.should be_a_kind_of(RubyValve::AbortError)
      @after_raise.exception.message.should eql("Ug")
    end    

  end  
end