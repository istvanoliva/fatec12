CREATE OR REPLACE FUNCTION fn_consultar_saldo(
    p_cod_cliente INT,
    p_cod_conta INT
) RETURNS NUMERIC(10, 2) AS $$
DECLARE
    v_saldo NUMERIC(10, 2);
BEGIN
    SELECT saldo
    INTO v_saldo
    FROM tb_conta
    WHERE cod_cliente = p_cod_cliente
      AND cod_conta = p_cod_conta;

    RETURN v_saldo;
END;
$$ LANGUAGE plpgsql;

-- Bloco anônimo para testar a função
DO $$
DECLARE
    v_cod_cliente INT := 1;
    v_cod_conta INT := 1;
    v_saldo NUMERIC(10, 2);
BEGIN
    SELECT fn_consultar_saldo(v_cod_cliente, v_cod_conta) INTO v_saldo;
    RAISE NOTICE 'O saldo da conta é: R$%s', v_saldo;
END;
$$;
