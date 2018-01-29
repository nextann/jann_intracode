# Author: Jin Chul Ann
# Intra_Function Code Generation
# file name: token.rb
# creates an object Token to be used in the scanner class
class Token

  attr_accessor :type
  attr_accessor :name

  def initialize(type, name)
    self.type = type
    self.name = name
  end

  def to_string
    type + " : " + name
  end

end
