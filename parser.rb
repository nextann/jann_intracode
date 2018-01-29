#!/usr/bin/env ruby
load 'scanner.rb'
# Author: Jin Chul Ann
# Intra_Function Code Generation
# file name: parser.rb
# uses scanner class to use the tokens that were created from the testfiles and parses and returns whether it passed the grammar or not
# returns number of variables, functions and statements
# if file does not support the given grammar returns error

class Parser

	attr_accessor :tokens
	attr_accessor :cur_tok
	attr_accessor :var
	attr_accessor :funct
	attr_accessor :stat
	attr_accessor :parsed
	attr_accessor :counter
	attr_accessor :counter2
	attr_accessor :while_gotos
	attr_accessor :while_const
	attr_accessor :gvar
	attr_accessor :lvar
	attr_accessor :temp_list
	attr_accessor :param_list

	def initialize (tokens)
		@tokens = tokens
		@cur_tok = @tokens[0]
		@var = 0
		@funct = 0
		@stat = 0
		@parsed = []
		@counter = 0
		@counter2 = 0
		@while_gotos = []
		@while_const = -1
		@gvar = []
		@lvar = []
		@temp_list = []
		@param_list = []
	end

	#<program> --> <metastat> <data_decls_global> <func_list>
	def program
		result = []
		skip_meta
		@parsed << @temp_list
		result << data_decls(1)
		if result[-1] != ""
			@parsed << result[-1] + " gvar[" + @gvar.count.to_s + "];"
		end
		@temp_list = []
		result << func_list
		return result
	end

	#<func_list --> <metastat> <func> <func_list> | epsilon
	def func_list
		result = []
		skip_meta
		if match_name("void") or match_name("int")
			result << func
			result << func_list
		end
		return result
	end

	#<func> --> <func_decl> ; | <func_decl> { <data_decls> <statements> } <metastat>
	def func
		result = [func_decl]
		if match_type("semicolon")
			post
			result << ";"
			@parsed.insert(-1,";")
		elsif match_type("lf_brace")
			post
			result << "{"
			@parsed.insert(-1,"{")
			result = ""
			result = data_decls(0)
			statements
			if result != ""
				@parsed.insert(-1, result + " lvar[" + @lvar.count.to_s + "];")
			elsif result == "" and @lvar.count != 0
				@parsed.insert(-1, "int " + "lvar[" + @lvar.count.to_s + "];")
			end
			add_to_list("rt_brace", 1, 1, 1)
			@parsed.insert(-1, @temp_list)
			@funct += 1
			@lvar = []
			@param_list = []
		end
		@temp_list = []
		skip_meta
		@parsed.insert(-1, @temp_list)
		@temp_list = []
		return result
	end

	#<func_decl> --> <type_name> ID ( <parameter_list> )
	def func_decl
		@temp_list.insert(-1,@cur_tok.name)
		result = [type_name]
			if match_type("identifier") or match_name("main")
				result << @cur_tok.name
				@temp_list.insert(-1, @cur_tok.name)
				post
				result << add_to_list("lf_paren", 1, 1, 1)
				result << parameter_list
				result << add_to_list("rt_paren", 1, 1, 1)
				skip_meta
			end
		@parsed.insert(-1, temp_list)
		@temp_list = []
		return result
	end

	#<type_name> --> int | void
	def type_name
		result = ""
		if match_name("void") or match_name("int")
			result = @cur_tok.name
			post
		else
			abort("Error18")
		end
		return result
	end

	#<parameter_list --> epsilon | void | <non_empty_list>
	def parameter_list
		result = []
		if match_name("void")
			result << "void"
			post
		elsif look.type == "identifier"
			result << non_empty_list
		end
		@temp_list.insert(-1, result)
		return result
	end

	#<non_empty_list --> <type_name> ID <non_empty_list_tail>
	def non_empty_list
		result = [type_name]
		@param_list << @cur_tok.name
		result << add_to_list("identifier", 1, 1, 0)
		result << non_empty_list_tail
		return result
	end

	#<non_empty_list_tail> --> epsilon | comma <type_name> ID <non_empty_list_tail>
	def non_empty_list_tail
		result = []
		if match_type("comma")
			result << ","
			post
			result << type_name
			@param_list << @cur_tok.name
			result << add_to_list("identifier", 1, 1, 0)
			result << non_empty_list_tail
		end
		return result
	end

	#<data_decls> --> epsilon | <type_name> <id_list> semicolon <data_decls>
	def data_decls(global)
		result = ""
		skip_meta
		temp_tok = @tokens
		if match_name("void") or match_name("int")
			result = type_name
			if (match_type("identifier") or match_name("main")) and look.type == "lf_paren"
				@tokens = temp_tok
				@cur_tok = @tokens[0]
				return ""
			end
			id_list(global)
			add_to_list("semicolon", 1, 1, 0)
			data_decls(global)
		end
		if result == ""
			return result
		end
		return result
	end

	#<id_list> --> <id> <id_list_tail>
	def id_list(global)
		result = [id(global)]
		@var += 1
		result << id_list_tail(global)
		if global == 1
			return "gvar"
		end
		return "lvar"
	end

	#<id_list_tail> --> epsilon | , <id> <id_list_tail>
	def id_list_tail(global)
		result = []
		if match_name(",")
			post
			result << ","
			result << id(global)
			@var += 1
			result << id_list_tail(global)
		end
		return result
	end

	#<id> --> ID | ID ( <expression )
	def id(global)
		result = [@cur_tok.name]
		post
		if match_type("lf_brack")
			result << "["
			post
			temp = @tokens
			i = 0
			while temp[i].type != "rt_brack"
				if temp[i].type == "identifier"
					abort("Error1")
				end
				i += 1
			end
			result << expression(global)
			result << add_to_list("rt_brack", 1, 1, 0)
		end
		x = result.flatten.join()
		if global == 1
			if @gvar.include? x
				return result
			end
			@gvar << x
		elsif global == 0
			if @gvar.include? x or @lvar.include? x
				return result
			end
			@lvar << x
		end
		return result
	end

	#<block_statements> --> { <statements> }
	def block_statements
		result = []
		if match_type("lf_brace")
			post
			result << statements
			if match_type("rt_brace")
				post
			else
				abort("Error2")
			end
		else
			abort("Error3")
		end
		return ""
	end

	#<statements> --> epsilon | <statement> <statements>
	def statements
		result = []
		skip_meta
		case @cur_tok.name
		when "break", "continue", "return", "while", "if", "scanf", "printf"
			@stat += 1
			result << statement
			result << statements
		else
			if match_type("identifier")
				@stat += 1
				result << statement
				result << statements
			end
		end
		return result
	end

	# <statement> --> <assignment> | <general func call> | <printf func call> | <scanf func call> | <if statement> | <while statement> | <return statement> | <break statement> | <continue statement>
	def statement
		result = []
		case @cur_tok.name
		when "break"
			post
			if @while_gotos[@while_const] == nil
				abort("Error4")
			end
			temp = []
			temp << @while_gotos[@while_const]
			temp << add_to_list("semicolon", 1, 1, 0)
			result << temp
			@temp_list.insert(-1,result)
		when "continue"
			post
			if @while_gotos[@while_const - 1] == nil
				abort("Error5")
			end
			temp = []
			temp << @while_gotos[@while_const - 1]
			temp << add_to_list("semicolon", 1, 1, 0)
			result << temp
			@temp_list.insert(-1,temp)
		when "return"
			temp = []
			post
			temp << "return"
			if is_express
				temp << expression(0)
			end
			temp << add_to_list("semicolon", 1, 1, 0)
			result << temp
			@temp_list.insert(-1,result)
		when "while"
			result << while_statement
			@temp_list.insert(-1,result)
		when "if"
			result << if_statement
			@temp_list.insert(-1,result)
		when "scanf"
			post
			result << "scanf"
			result << add_to_list("lf_paren", 1, 1, 0)
			result << add_to_list("string", 1, 1, 0)
			if match_type("comma")
				post
				result << ","
				result << expression(0)
			end
			result << add_to_list("rt_paren", 1, 1, 0)
			result << add_to_list("semicolon", 1, 1, 0)
			@temp_list.insert(-1,result)
		when "printf"
			temp = []
			post
			temp << "printf"
			temp << add_to_list("lf_paren", 1, 1, 0)
			temp << add_to_list("string", 1, 1, 0)
			if match_type("comma")
				post
				temp << ","
				temp << expression(0)
			end
			temp << add_to_list("rt_paren", 1, 1, 0)
			temp << add_to_list("semicolon", 1, 1, 0)
			result << temp
			@temp_list.insert(-1,result)
		else
			if match_type("identifier")
				result << statement_tail(0)
			end
			if result[0] == nil
				return result
			end
		end
		return result
	end
	#<while statement> --> while left_parenthesis <condition expression> right_parenthesis <block statements>
	def while_statement
		post
		temp = []
		temp << "if"
		temp << add_to_list("lf_paren", 1, 1, 0)
		temp << condition_expression(0)
		temp << add_to_list("rt_paren", 1, 1, 0)
		top_label = newlabel
		cur_label = newlabel
		@while_gotos << "goto " + top_label
		@while_gotos << "goto " + cur_label + "f"
		@temp_list.insert(-1, top_label + ":;")
		@temp_list.insert(-1, temp)
		@temp_list.insert(-1, "goto " + cur_label + "t;")
		@temp_list.insert(-1, "goto " + cur_label + "f;")
		@temp_list.insert(-1, cur_label + "t:;")
		block_statements
		@while_const -= 2
		@temp_list.insert(-1, "goto " + top_label + ";")
		@temp_list.insert(-1, cur_label + "f:;")
		return ""
	end

	#<if statement> --> if left_parenthesis <condition expression> right_parenthesis <block statements> | if left_parenthesis <condition expression> right_parenthesis <block statements> else <block statements>
	def if_statement
		temp = []
		post
		temp << "if"
		temp << add_to_list("lf_paren", 1, 1, 0)
		temp << condition_expression(0)
		temp << add_to_list("rt_paren", 1, 1, 0)
		@temp_list.insert(-1,temp)
		cur_label = newlabel
		@temp_list.insert(-1, "goto " + cur_label + "t;")
		@temp_list.insert(-1, "goto " + cur_label + "f;")
		@temp_list.insert(-1, cur_label + "t:;")
		block_statements
		@temp_list.insert(-1, cur_label + "f:;")
		if match_name("else")
			post
			temp << block_statements
		end
		return ""
	end

	#<statement_tail> --> ID ( <expr_list> ) ; | ID = <expression> ;
	def statement_tail(global)
		result = []
		if look.type == "lf_paren"
			temp = []
			temp << @cur_tok.name
			post
			temp << "("
			post
			temp << expr_list(global)
			temp << add_to_list("rt_paren", 1, 1, 0)
			temp << add_to_list("semicolon", 1, 1, 0)
			result << temp
			@temp_list.insert(-1,result)
		else
			temp = []
			x = id(global).flatten.join()
			if @gvar.include? x
				temp << "gvar[" + @gvar.index(x).to_s + "]"
			elsif @lvar.include? x
				temp << "lvar[" + @lvar.index(x).to_s + "]"
			else
				abort("Error")
			end
			temp << add_to_list("equal_sign", 1, 1, 0)
				if is_express
					temp << expression(global)
					temp << add_to_list("semicolon", 1, 1, 0)
				else
					abort("Error6")
				end
			result << temp
			@temp_list.insert(-1,result)
		end
		return result
	end

	#<expr_list> --> epsilon | <non_empty_expr_list>
	def expr_list(global)
		result = ""
		if is_express
			result += non_empty_expr_list(global)
		end
		return result
	end

	#<non_empty_expr_list> --> <expression> <non_empty_expr_list_tail>
	def non_empty_expr_list(global)
		result = expression(global)
		result += non_empty_expr_list_tail(global)
		return result
	end

	#<non_empty_expr_list_tail> --> epsilon | , <expression> <non_empty_expr_list_tail>
	def non_empty_expr_list_tail(global)
		result = ""
		if match_type("comma")
			result += ","
			post
			if is_express
				result += expression(global)
				result += non_empty_expr_list_tail(global)
			else
				abort("Error7")
			end
		end
		return result
	end

	#<condition_expression> --> <condition> | <condition> <double and/or> <condition
	def condition_expression(global)
		result = [condition(global)]
		if match_type("double_and") or match_type("double_or")
			result << @cur_tok.name
			post
			result << condition(global)
		end
		return result
	end

	#<condition> --> <expression> <comparison_op> <expression>
	def condition(global)
		result = []
		if is_express
			result << expression(global)
			case @cur_tok.type
				when "double_equals", "not_equal", "greater", "greater_equals", "less", "less_equals"
				result << @cur_tok.name
				post
				if is_express
					result << expression(global)
				else
					abort("Error8")
				end
			else
				abort("Error9")
			end
		else
			abort("Error10")
		end

		return result
	end

	#<expression> --> <term> | <term> <add/minus> <term>
	def expression(global)
  		result = term(global)
  		while match_type("plus_sign") or match_type("minus_sign")
  			if match_type("plus_sign")
	 	     	result += "+"
		  		post
	  			result += term(global)
	  		end
	  		if match_type("minus_sign")
	  	    	result += "-"
	  			post
	  			result += term(global)
	  		end
	  		temp = newtemp
	  		if global == 1
	  			@gvar << temp
	  			@temp_list.insert(-1, "gvar[" + @gvar.index(temp).to_s + "]" + "=" + result + ";")
	  		elsif global == 0
	  			@lvar << temp
	  			@temp_list.insert(-1, "lvar[" + @lvar.index(temp).to_s + "]" + "=" + result + ";")
	  		end
	  		if global == 1
	  			result = "gvar[" + @gvar.index(temp).to_s + "]"
	  		elsif global == 0
	  			result = "lvar[" + @lvar.index(temp).to_s + "]"
	  		end
  		end
  		return result
  	end

  	#<term> --> <factor> | <factor <mult/divide> <term>
 	def term(global)
  		result = factor(global)
  		while match_type("star_sign") or match_type("forward_slash")
  			if match_type("star_sign")
	      		result += "*"
	  			post
	  			result += term(global)
	  		end
	  		if match_type("forward_slash")
		      	result += "/"
	  			post
	  			result += term(global)
	  		end
	  		temp = newtemp
	  		if global == 1
	  			@gvar << temp
	  			@temp_list.insert(-1, "gvar[" + @gvar.index(temp).to_s + "]" + "=" + result + ";")
	  		elsif global == 0
	  			@lvar << temp
	  			@temp_list.insert(-1, "lvar[" + @lvar.index(temp).to_s + "]" + "=" + result + ";")
	  		end
	  		if global == 1
	  			result = "gvar[" + @gvar.index(temp).to_s + "]"
	  		elsif global == 0
	  			result = "lvar[" + @lvar.index(temp).to_s + "]"
	  		end
  		end
  		return result
  	end

  	#<factor> --> NUMBER | ID | ID ( <expr_list> ) | ID [ <expression> ] | ( <expression> )
  	def factor(global)
  		result = ""
  		case @cur_tok.type
  		when "number"
  			result += @cur_tok.name.to_s
  			post
  			return result
  		when "identifier"
  			result += @cur_tok.name
  			post
  			case @cur_tok.type
  			when "lf_paren"
  				result += "("
  				post
  				result += expr_list(global)
				result += add_to_list("rt_paren", 1, 1, 0)
				return result
  			when "lf_brack"
  				result += "["
  				post
  				temp = @tokens
  				i = 0
  				while temp[i].type != "rt_brack"
					if temp[i].type == "identifier"
						abort("Error11")
					end
					i += 1
				end
  				if is_express
	  				result += expression(global)
	  				result += add_to_list("rt_brack", 1, 1, 0)
	  			else
	  				abort("Error12")
	  			end
  			end
  		when "lf_paren"
  			post
  			if is_express

  				result += expression(global)
				nope = add_to_list("rt_paren", 1, 1, 0)
			else
				abort("Error13")
			end
			if global == 0
				tempp = @lvar.count-1
				return "lvar[" + tempp.to_s +  "]"
			elsif global == 1
				tempp = @gvar.count-1
				return "gvar[" + tempp.to_s +  "]"
			end
		else
			abort("Error14")
		end
		if result != ""
			if result.class == Array
				result = result.flatten.join()
			end
			if global == 1
				if !(@gvar.include? result)
					@gvar << result
				end
				result = "gvar[" + @gvar.index(result).to_s + "]"
			elsif global == 0
				if @gvar.include? result
					return "gvar[" + @gvar.index(result).to_s + "]"
				end
				if @param_list.include? result
					return result
				end
				if !(@lvar.include? result)
					@lvar << result
				end
				result = "lvar[" + @lvar.index(result).to_s + "]"
			end
		end
  		return result
  	end

  	#post finds the next token
	def post
		temp, *@tokens = @tokens
		@cur_tok = @tokens[0] if @tokens.length > 0 rescue nil
	end

	#look is peeking the next token
	def look
		@tokens[1]
	end

	#matches type
	def match_type(type)
		@cur_tok.type == type
	end

	#matches name
	def match_name(name)
		@cur_tok.name == name
	end

	def skip_meta
		while match_type("metastat")
			@temp_list.insert(-1, @cur_tok.name)
			post
		end
	end
	#checks whether the next token is expression
	def is_express
		match_type("number") or match_type("identifier") or match_type("lf_paren")
	end

	#checks whether the next token is operand
	def is_operand
		match_type("number") or match_type("identifier")
	end

	#creating newtemp for code generation of 3 variables on RHS on assignment or any operations
	def newtemp
		@counter += 1
		"t" + @counter.to_s
	end

	def newlabel
		@counter2 += 1
		"l" + @counter2.to_s
	end

	def add_to_list(tok, type, error, inserto)
		temp = ""
		if type == 1
			if match_type(tok)
				temp = @cur_tok.name
				post
			else
				if error == 1
					abort("Error15")
				end
			end
		else
			if match_name(tok)
				temp = @cur_tok.name
				post
			else
				if error == 1
					abort("Error16")
				end
			end
		end
		if inserto == 1
			@temp_list.insert(-1,temp)
		end
		return temp
	end
end

filename = ARGV.first
file = File.open(filename, 'r')
x = []
while !file.eof
  line = file.readline
  if !(line.ord == 13)
    do_token = Scanner.new line
    y = do_token.tokenize
    x = x + y
  end
end

parse = Parser.new x
l = parse.program
ll = parse.parsed.flatten
puts "Pass"
print "\tVariables: " + parse.var.to_s + "\n"
print "\tFunctions: " + parse.funct.to_s + "\n"
print "\tStatements: " + parse.stat.to_s + "\n"

z = ""
ll.each do |lll|
	if lll.include?(";") or lll.include?("//") or lll.include?("{") or lll.include?("}") or lll.include?("#")
		z += lll + "\n"
	else
		z += lll + " "
	end
end

if ARGV[1] == nil
	wr = File.open("output.c", 'w')
	wr.puts z
	wr.close
else
	wr = File.open(ARGV[1], 'w')
	wr.puts z
	wr.close
end
file.close
