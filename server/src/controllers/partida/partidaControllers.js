import { pool } from '../../config/db/db.js';

/**
 * Iniciar partida
 * 
 * POST /partida/start
 * Body: { session_id, juego_id, nivel_id }
 * 
 * Crea un registro en la tabla partidas con estado "en curso".
 * Devuelve partida_id.
 */
export const partidaStart = async (req, res) => {
  const { session_id, juego_id, nivel_id } = req.body || {};

  if (!session_id || !juego_id || !nivel_id) {
    return res.status(400).json({ error: 'session_id, juego_id y nivel_id son requeridos' });
  }

  const conn = await pool.getConnection();
  try {
    const [result] = await conn.query(
      `INSERT INTO partidas (session_id, juego_id, nivel_id, estado)
       VALUES (?, ?, ?, 'en curso')`,
      [session_id, juego_id, nivel_id]
    );

    return res.status(201).json({
      partida_id: result.insertId,
      session_id,
      juego_id,
      nivel_id,
      estado: 'en curso'
    });
  } catch (err) {
    console.error('PARTIDA_START_ERROR', err);
    return res.status(500).json({ error: 'Error al iniciar la partida' });
  } finally {
    conn.release();
  }
};

/**
 * Finalizar partida
 * 
 * POST /partida/end
 * Body: { partida_id, estado, tiempo }
 * 
 * Actualiza la partida como "completada" o "abandonada".
 * También registra la duración total (en segundos).
 */
export const partidaEnd = async (req, res) => {
  const { partida_id, estado, tiempo } = req.body || {};

  if (!partida_id || !estado) {
    return res.status(400).json({ error: 'partida_id y estado son requeridos' });
  }

  const conn = await pool.getConnection();
  try {
    const [result] = await conn.query(
      `UPDATE partidas
          SET estado = ?, tiempo = ?
        WHERE partida_id = ?`,
      [estado, tiempo || null, partida_id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Partida no encontrada' });
    }

    return res.status(200).json({
      partida_id,
      estado,
      tiempo: tiempo || null,
      updated: true
    });
  } catch (err) {
    console.error('PARTIDA_END_ERROR', err);
    return res.status(500).json({ error: 'Error al finalizar la partida' });
  } finally {
    conn.release();
  }
};

/**
 * Registrar evento
 * 
 * POST /evento/add
 * Body: { partida_id, tipo, secuencia }
 * 
 * Inserta un evento ligado a una partida.
 * - Si el tipo es "ui.reset" incrementa numero_reinicios en la partida.
 * - Para cualquier otro evento incrementa numero_movimientos.
 */
export const eventoAdd = async (req, res) => {
  const { partida_id, tipo, secuencia } = req.body || {};

  if (!partida_id || !tipo || !secuencia) {
    return res.status(400).json({ error: 'partida_id, tipo y secuencia son requeridos' });
  }

  const conn = await pool.getConnection();
  try {
    // 1. Insertar evento en tabla eventos
    const [result] = await conn.query(
      `INSERT INTO eventos (partida_id, tipo, secuencia)
       VALUES (?, ?, ?)`,
      [partida_id, tipo, secuencia]
    );

    // 2. Actualizar métricas de la partida
    if (tipo === 'ui.reset') {
      await conn.query(
        `UPDATE partidas
            SET numero_reinicios = numero_reinicios + 1
          WHERE partida_id = ?`,
        [partida_id]
      );
    } else {
      await conn.query(
        `UPDATE partidas
            SET numero_movimientos = numero_movimientos + 1
          WHERE partida_id = ?`,
        [partida_id]
      );
    }

    return res.status(201).json({
      evento_id: result.insertId,
      partida_id,
      tipo,
      secuencia,
      registrado: true
    });
  } catch (err) {
    console.error('EVENTO_ADD_ERROR', err);
    return res.status(500).json({ error: 'Error al registrar evento' });
  } finally {
    conn.release();
  }
};