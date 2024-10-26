#!/usr/bin/perl
use strict;
use warnings;
use CGI;

# Crear una nueva instancia de CGI para manejar la entrada y salida
my $cgi = CGI->new;
print $cgi->header(-type => 'text/html', -charset => 'UTF-8');

# Obtener la operación ingresada por el usuario
my $entrada_operacion = $cgi->param('operacion') || "";

# Inicializar resultado
my $resultado_final = "";
if (defined $entrada_operacion && $entrada_operacion ne '') {
    chomp($entrada_operacion);
    $resultado_final = calcular_expresion($entrada_operacion);
}

# Procesar la expresión matemática
sub calcular_expresion {
    my ($expresion) = @_;
    
    # Reemplazar "raiz(n)" por su valor evaluado usando sqrt
    $expresion =~ s/raiz\((\d+)\)/sqrt($1)/eg;
    
    # Limpiar la expresión, permitiendo solo ciertos caracteres
    $expresion =~ s/[^0-9+\-*\/\(\)\s\*\*]//g;
    
    # Dividir la expresión en tokens
    my @tokens = extraer_tokens($expresion);
    
    # Convertir la notación infija a postfija
    my @resultado_postfijo = infija_a_postfija(@tokens);
    
    # Evaluar la expresión en notación postfija
    my $resultado = evaluar_postfijo(@resultado_postfijo);
    return $resultado;
}

# Dividir la expresión en tokens
sub extraer_tokens {
    my ($expresion) = @_;
    
    # Extraer números y operadores
    my @tokens = ($expresion =~ /(\d+|\*\*|\+|\-|\*|\/|\(|\))/g);
    return @tokens;
}

# Convertir expresión infija a postfija
sub infija_a_postfija {
    my @tokens = @_;
    my @resultado;
    my @pila;

    # Definir la precedencia de los operadores
    my %precedencia = (
        '+'  => 1,
        '-'  => 1,
        '*'  => 2,
        '/'  => 2,
        '**' => 3,
    );

    # Procesar cada token
    for my $token (@tokens) {
        if ($token =~ /^[0-9]+$/) {  # Si es un número
            push @resultado, $token;
        } elsif ($token eq '(') {  # Si es un paréntesis de apertura
            push @pila, $token;
        } elsif ($token eq ')') {  # Si es un paréntesis de cierre
            while (@pila && $pila[-1] ne '(') {
                push @resultado, pop @pila;  # Sacar de la pila hasta encontrar '('
            }
            pop @pila;  # Quitar el paréntesis de apertura
        } else {  # Si es un operador
            while (@pila && $precedencia{$token} <= $precedencia{$pila[-1]}) {
                push @resultado, pop @pila;  # Pasar operadores de mayor o igual precedencia
            }
            push @pila, $token;  # Añadir el operador a la pila
        }
    }
    push @resultado, pop @pila while @pila;  # Pasar cualquier operador restante
    return @resultado;
}

# Evaluar expresión en notación postfija
sub evaluar_postfijo {
    my @tokens = @_;
    my @pila;

    # Procesar cada token en la notación postfija
    for my $token (@tokens) {
        if ($token =~ /^[0-9]+$/) {  # Si es un número
            push @pila, $token;
        } else {  # Si es un operador
            my $segundo_operando = pop @pila;  # Sacar el segundo operando
            my $primer_operando = pop @pila;  # Sacar el primer operando
            if ($token eq '+') {
                push @pila, $primer_operando + $segundo_operando;
            } elsif ($token eq '-') {
                push @pila, $primer_operando - $segundo_operando;
            } elsif ($token eq '*') {
                push @pila, $primer_operando * $segundo_operando;
            } elsif ($token eq '/') {
                if ($segundo_operando == 0) {
                    return "No se puede dividir por cero";
                }
                push @pila, $primer_operando / $segundo_operando;
            } elsif ($token eq '**') {
                push @pila, $primer_operando ** $segundo_operando;
            }
        }
    }
    return pop @pila;  # Devolver el resultado final
}

# Generar HTML de respuesta
print <<HTML;
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lab 05 - Calculator</title>
    <link rel="stylesheet" href="/css/mystyle.css">
</head>
<body>
    <div class="container">
        <h1>Lab 05: Expresiones regulares en Perl</h1>
        <form action="/cgi-bin/calcul.pl" method="get">
            <input type="text" name="operacion" placeholder="operacion" required>
            <br>
            <input type="submit" value="Calcular">
        </form>
        <p id="result">Resultado: <span id="output">$resultado_final</span></p>
    </div>
</body>
</html>
HTML
