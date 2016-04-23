module TransfersHelper
	def currency(value)
		str = value.to_s
		currency = ""
		while str.length > 3
			currency = ",#{str[-3,3]}#{currency}"
			str = str[0...-3]
		end
		return "£#{str}#{currency}"
	end
end
