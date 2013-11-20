require 'spec_helper'

DummyValve = Class.new(RubyValve::Base) do
  define_method(:step_1) {}
  define_method(:step_2) {}
  define_method(:step_3) {}
end

describe RubyValve::Base do
  before(:each) do
    @valve = DummyValve.new
  end

  it "should execute all step methods in order" do
    @valve.execute
    @valve.executed_steps.should eql([:step_1, :step_2, :step_3])
  end

  context "#skip should make it skip a step" do
    before(:each) do

      class SkipValve < RubyValve::Base 
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
      @skip_valve.executed_steps.should eql([])  
    end
  end
  # context ".executed_steps" do
  #   it "should re"
  # end


end