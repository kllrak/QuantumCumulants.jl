using Latexify
import MacroTools
using LaTeXStrings

tsym_latex = Ref(:t)

function _postwalk_func(x)
    if x==:𝟙
        return "\\mathbb{1}"
    elseif x==:im
        return :i
    elseif MacroTools.@capture(x, dagger(arg_))
        s = "$(arg)^\\dagger"
        return s
    elseif MacroTools.@capture(x, Transition(arg_,i_,j_,k_))
        if k==default_index()
            s = "$(arg)^{$(i)$(j)}"
        else
            s = "$(arg)^{$(i)$(j)}_{$(k.i)}"
        end
        return s
    elseif MacroTools.@capture(x, arg_[i_])
        if i isa Index
            return "$(arg)_{$(i.i)}"
        else
            return "$(arg)_{$(i)}"
        end
    else
        return x
    end
end

function _postwalk_average(x)
    if MacroTools.@capture(x, AVERAGE(arg_))
        arg = MacroTools.postwalk(_postwalk_func, arg)
        # TODO: clean up; tricky because of nested string conversion of eg average(dagger(a))
        s = string(arg)
        s = replace(s, "\"" => "")
        s = replace(s, "\\\\" => "\\")
        s = replace(s, "*" => "")
        s = "\\langle " * s * "\\rangle "
        return s
    end
    return x
end

@latexrecipe function f(de::AbstractEquation)
    # Options
    env --> :align
    cdot --> false

    lhs, rhs = _latexify(de.lhs,de.rhs)
    return lhs, rhs
end

function _latexify(lhs_::Vector, rhs_::Vector)

    # Convert eqs to Exprs
    rhs = _to_expression.(rhs_)
    rhs = [MacroTools.postwalk(_postwalk_func, eq) for eq=rhs]
    rhs = [MacroTools.postwalk(_postwalk_average, eq) for eq=rhs]
    lhs = _to_expression.(lhs_)
    lhs = [MacroTools.postwalk(_postwalk_func, eq) for eq=lhs]
    lhs = [MacroTools.postwalk(_postwalk_average, eq) for eq=lhs]

    tsym = tsym_latex[]
    dt = Symbol(:d, tsym)
    ddt = :(d/$(dt))
    lhs = [:($ddt * ($l)) for l=lhs]

    return lhs, rhs
end
_latexify(lhs,rhs) = _latexify([lhs],[rhs])

@latexrecipe function f(op::AbstractOperator)
    # Options
    cdot --> false

    ex = _to_expression(op)
    ex = MacroTools.postwalk(_postwalk_func, ex)
    ex = MacroTools.postwalk(_postwalk_average, ex)
    ex = isa(ex,String) ? LaTeXString(ex) : ex
    return ex
end

@latexrecipe function f(s::SymbolicNumber)
    # Options
    cdot --> false

    ex = _to_expression(s)
    ex = MacroTools.postwalk(_postwalk_func, ex)
    ex = MacroTools.postwalk(_postwalk_average, ex)
    ex = isa(ex,String) ? LaTeXString(ex) : ex
    return ex
end