#!/usr/bin/env ruby
load 'token.rb'
# Author: Jin Chul Ann
# Class: CSC 254 Fall 2014 MW 2-3PM
# Professor: Chen Ding
# TA: Jake Brock, Kevin Hu
# Homework 4: Compiler Project - Part 4: Intra_Function Code Generation Part2
# file name: scanner.rb
# scanner takes the input file name as an argument and outputs into output.c



class Scanner 
  

  def initialize(line)
    @position = -1; #starts from -1 as the "next_token" function increments first
    @cur_line = line
    @cur_char = ""
    @prev_tok = ""
  end
 
  
  # return the next token (as a Token object ) or EOF
  def next_token
    #increments to get to the next char
    @position += 1
    @cur_char = @cur_line[@position, 1]
    
    while is_white(@cur_char) #skip white spaces
      @position += 1
      @cur_char = @cur_line[@position, 1]
      if end_of_line
        return nil
      end
    end
    name = ""
    case @cur_char
      when "("
        @prev_tok = "("
        return Token.new("lf_paren", "(")
      when ")"
        @prev_tok = ")"
        return Token.new("rt_paren", ")")
      when "{"
        @prev_tok = "{"
        return Token.new("lf_brace", "{")
      when "}"
        @prev_tok = "}"
        return Token.new("rt_brace", "}")
      when "["
        @prev_tok = "["
        return Token.new("lf_brack", "[")
      when "]"
        @prev_tok = "]"
        return Token.new("rt_brack", "]")
      when ","
        @prev_tok = ","
        return Token.new("comma", ",")
      when ";"
        @prev_tok = ";"
        return Token.new("semicolon", ";")
      when "+"
        @prev_tok = "+"
        return Token.new("plus_sign", "+")
      when "-"
          name = @cur_char
          while is_digit(@cur_line[@position+1,1])
            @position += 1
            @cur_char = @cur_line[@position,1]
            name += @cur_char
          end
          @prev_tok = name
          if (name.to_i.to_s == name)
            return Token.new("number", name)
          end
          return Token.new("minus_sign", name)
      when "*"
        @prev_tok = "*"
        return Token.new("star_sign", "*")
      when "/"
        if @cur_line[@position+1,1] == "/"
          name = @cur_char + "/"
          @position += 2
          @cur_char = @cur_line[@position, 1]
          while !(is_new(@cur_line[@position+1,1]))
            @position += 1
            @cur_char = @cur_line[@position, 1]
            name += @cur_char
          end
          @cur_char = ""
          @prev_tok = name
          return Token.new("metastat", name)
        end
        @prev_tok = "/"
        return Token.new("forward_slash", "/")
      when ">"
        if @cur_line[@position+1,1] == "="
          @position += 1
          @cur_char = @cur_line[@position, 1]
          @prev_tok = ">="
          return Token.new("greater_equals", ">=")
        end
        @prev_tok = ">"
        return Token.new("greater", ">")
      when "<"
        if @cur_line[@position+1,1] == "="
          @position += 1
          @cur_char = @cur_line[@position, 1]
          @prev_tok = "<="
          return Token.new("less_equals", "<=")
        end
        @prev_tok = "<"
        return Token.new("less", "<")
      when "="
        if @cur_line[@position+1,1] == "="
          @position += 1
          @cur_char = @cur_line[@position, 1]
          @prev_tok = "=="
          return Token.new("double_equals", "==")
        end
        @prev_tok = "="
        return Token.new("equal_sign", "=")
      when "&"
        if @cur_line[@position+1,1] == "&"
          @position += 1
          @cur_char = @cur_line[@position, 1]
          @prev_tok = "&&"
          return Token.new("double_and", "&&")
        end
        @prev_tok = "&"
        return Token.new("and_sign", "&")
      when "|"
        if @cur_line[@position+1,1] == "|"
          @position += 1
          @cur_char = @cur_line[@position, 1]
          @prev_tok = "||"
          return Token.new("double_or", "||")
        end
        @prev_tok = "|"
        return Token.new("or_sign", "|")
      when "!"
        if @cur_line[@position+1,1] == "="
          @position += 1
          @cur_char = @cur_line[@position, 1]
          @prev_tok = "!="
          return Token.new("not_equal", "!=") 
        end
        @prev_tok = "!"
        return Token.new("not_sign", "!")
      when "\""
        name += "\""
        while !(@cur_line[@position+1,1] == "\"")
          @position += 1
          @cur_char = @cur_line[@position, 1]
          name += @cur_char
        end
        @position += 1
        @cur_char = "\""
        @prev_tok = "name" + "\""
        return Token.new("string", name + "\"")
      # starting with "#"
      when "#"
        name = "#"
        while !end_of_line
          @position += 1
          @cur_char = @cur_line[@position, 1]
          name += @cur_char
        end
        @cur_char = ""
        @prev_tok = name
        return Token.new("metastat", name)
    end
    
    # reserved word & identifiers
    if (is_letter(@cur_char))
      name = next_word
      if (name == "break" or name == "continue" or name == "if" or name == "int" or name == "main" or name == "printf" or name == "return" or name == "scanf" or name == "void" or name == "while" or name == "else")
        @prev_tok = name
        return Token.new("reserved_word", name)
      end
      @prev_tok = name
      return Token.new("identifier", name)
    end
    
    # number
    if is_digit(@cur_char)
      name = @cur_char
      while is_digit(@cur_line[@position+1,1]) or is_letter(@cur_line[@position+1,1])
        @position += 1
        @cur_char = @cur_line[@position,1]
        name += @cur_char
      end
      @prev_tok = name
      if (name.to_i.to_s == name)
        return Token.new("number", name)
      end
      
      @prev_tok = name
      return Token.new("error", name)
    end
    
    @prev_tok = @cur_char
    return Token.new("error", @cur_char)
  end
  
  def tokenize #uses next_token to tokenize the whole C code
    ary = Array.new
    tok = ""
    while !end_of_line
      tok = next_token
      if tok == nil
        break
      end
      if tok.name.ord == 13 or tok.name == "" or tok.name == "\n"
        next
      else
        ary << tok
      end
      
    end
    if ary.length > 1 and ary[ary.length-1].name != ")" and ary[ary.length-1].name != ";" and ary[ary.length-1].name != "{" and ary[ary.length-1].name != "}" and ary[ary.length-1].name != ","
      ary.pop
    end
    i = 0
    while i < ary.length
      if ary[i].type == "error"
        puts ary[i].name 
        abort("ILLEGAL TOKEN ERROR")
      end
      i += 1
    end
    return ary
  end

  def is_white(char)
    (is_space(char) or is_new(char))
  end
  
  def is_space (char)
    (char == "\t" or char == " ")
  end
  
  def is_new (char)
    char == "\n" or (char == "" and @cur_line[@position+1, 1] == nil)
  end
  
  def is_letter(char)
    if char == nil or char == ""
      return false
    else
    (char.ord >= "a".ord and char.ord<= "z".ord) or (char.ord >= "A".ord and char.ord <= "Z".ord) or (char.ord == "_".ord)
    end
  end
  
  def is_digit(char)
    if char == nil or char == ""
      return false
    else
    (char.ord >= "0".ord and char.ord <= "9".ord)
    end
  end
  
  def next_word
    word = @cur_char
    while (!ending)
      
      @position += 1
      @cur_char = @cur_line[@position,1]
      word += @cur_char
    end
    return word
  end
  
  def ending
    i = @cur_line[@position+1,1]
    ending_symbols(i)
  end
  
  def ending_symbols (char)
    if is_white(char) or is_new(char) or char.ord == 13
      return true
    end
      char == "+" or char == "-" or char == "*" or char == "/" or char == "(" or char == ")" or char == ";" or char == "," or char == "[" or char == "]"
  end

  def neg_int (char)
      (char == "+" or char == "-" or char == "/" or char == "*" or char == "=" or char == "==" or char == "!=" or char == ">=" or char == "<=" or char == ">" or char == "<" or char == "!=" or char == "&" or char == "|")
  end

  def end_of_line
    if @cur_char == "" or @cur_char == nil
      if @position > @cur_line.length
        return true
      end
      return false
    else
      @cur_char.ord == 13
    end
  end
end

   