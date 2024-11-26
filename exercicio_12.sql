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


CREATE OR REPLACE FUNCTION fn_transferir(
    p_cod_cliente_origem INT,
    p_cod_conta_origem INT,
    p_cod_cliente_destino INT,
    p_cod_conta_destino INT,
    p_valor NUMERIC(10, 2)
) RETURNS BOOLEAN AS $$
DECLARE
    v_saldo_origem NUMERIC(10, 2);
    v_saldo_destino NUMERIC(10, 2);
BEGIN
    -- Verificar saldo da conta de origem
    SELECT saldo INTO v_saldo_origem
    FROM tb_conta
    WHERE cod_cliente = p_cod_cliente_origem
      AND cod_conta = p_cod_conta_origem;

    IF v_saldo_origem < p_valor THEN
        RETURN FALSE; -- Saldo insuficiente
    END IF;

    -- Atualizar saldo das contas
    UPDATE tb_conta
    SET saldo = saldo - p_valor
    WHERE cod_cliente = p_cod_cliente_origem
      AND cod_conta = p_cod_conta_origem;

    UPDATE tb_conta
    SET saldo = saldo + p_valor
    WHERE cod_cliente = p_cod_cliente_destino
      AND cod_conta = p_cod_conta_destino;

    -- Garantir que nenhuma conta ficou negativa
    SELECT saldo INTO v_saldo_origem
    FROM tb_conta
    WHERE cod_cliente = p_cod_cliente_origem
      AND cod_conta = p_cod_conta_origem;

    SELECT saldo INTO v_saldo_destino
    FROM tb_conta
    WHERE cod_cliente = p_cod_cliente_destino
      AND cod_conta = p_cod_conta_destino;

    IF v_saldo_origem < 0 OR v_saldo_destino < 0 THEN
        -- Reverter as alterações em caso de saldo negativo
        UPDATE tb_conta
        SET saldo = saldo + p_valor
        WHERE cod_cliente = p_cod_cliente_origem
          AND cod_conta = p_cod_conta_origem;

        UPDATE tb_conta
        SET saldo = saldo - p_valor
        WHERE cod_cliente = p_cod_cliente_destino
          AND cod_conta = p_cod_conta_destino;

        RETURN FALSE;
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Bloco anônimo para testar a função
DO $$
DECLARE
    v_cod_cliente_origem INT := 1;
    v_cod_conta_origem INT := 1;
    v_cod_cliente_destino INT := 2;
    v_cod_conta_destino INT := 2;
    v_valor NUMERIC(10, 2) := 500;
    v_resultado BOOLEAN;
BEGIN
    SELECT fn_transferir(
        v_cod_cliente_origem, v_cod_conta_origem,
        v_cod_cliente_destino, v_cod_conta_destino,
        v_valor
    ) INTO v_resultado;

    IF v_resultado THEN
        RAISE NOTICE 'Transferência concluída com sucesso.';
    ELSE
        RAISE NOTICE 'Falha na transferência.';
    END IF;
END;
$$;
