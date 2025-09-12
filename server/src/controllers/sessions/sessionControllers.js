import { pool } from '../../config/db/db.js';

/**
 * Construye un objeto DTO de usuario a partir de una fila de la vista.
 * 
 * @param {Object} row - Fila obtenida de la vista vw_auth_login
 * @returns {Object} - Datos simplificados del usuario (sin password)
 */
const buildUserDTO = (row) => ({
  id: row.usuario_id,
  usuario: row.usuario,
  rol_id: row.rol_id,
  rol: row.rol_nombre
});

/**
 * Controlador: Inicia una sesión de usuario.
 * 
 * Método: POST /session/start
 * Body esperado: { usuario: string, password?: string }
 * 
 * Flujo:
 *  1. Busca el usuario en la vista vw_auth_login.
 *  2. Si el rol es admin → requiere validar contraseña (texto plano en este prototipo).
 *  3. Si el rol es alumno → no requiere contraseña (campo password = NULL).
 *  4. Llama al SP sp_session_start para registrar la sesión.
 *  5. Devuelve los datos básicos del usuario + el session_id generado.
 */
export const sessionStart = async (req, res) => {
  const { usuario, password } = req.body || {};
  if (!usuario) {
    return res.status(400).json({ error: 'usuario es requerido' });
  }

  const conn = await pool.getConnection();
  try {
    // 1. Buscar usuario en la vista
    const [rows] = await conn.query(
      `SELECT usuario_id, usuario, password, rol_id, rol_nombre
         FROM vw_auth_login
        WHERE usuario = ?
        LIMIT 1`,
      [usuario]
    );

    if (rows.length === 0) {
      return res.status(401).json({ error: 'Credenciales inválidas' });
    }

    const row = rows[0];
    const requierePassword = row.password !== null;

    // 2. Validación según tipo de usuario
    if (requierePassword) {
      if (!password) {
        return res.status(401).json({ error: 'Contraseña requerida' });
      }
      if (password !== row.password) {
        return res.status(401).json({ error: 'Credenciales inválidas' });
      }
    }

    // 3. Crear sesión usando el SP
    const [sp] = await conn.query('CALL sp_session_start(?)', [row.usuario_id]);
    const session_id =
      sp?.[0]?.[0]?.session_id || sp?.[0]?.session_id || null;

    if (!session_id) {
      return res.status(500).json({ error: 'No se pudo crear la sesión' });
    }

    // 4. Respuesta exitosa
    return res.status(200).json({
      user: buildUserDTO(row),
      session_id
    });
  } catch (err) {
    console.error('SESSION_START_ERROR', err);
    return res.status(500).json({ error: 'Error interno' });
  } finally {
    conn.release();
  }
};

/**
 * Controlador: Cierra una sesión activa.
 * 
 * Método: POST /session/end
 * Body esperado: { session_id: string }
 * 
 * Flujo:
 *  1. Recibe el identificador de sesión.
 *  2. Llama al SP sp_session_end para marcar la finalización.
 *  3. Devuelve { closed: true } si la sesión se cerró correctamente.
 */
export const sessionEnd = async (req, res) => {
  const { session_id } = req.body || {};
  if (!session_id) {
    return res.status(400).json({ error: 'session_id requerido' });
  }

  const conn = await pool.getConnection();
  try {
    // 1. Ejecutar SP para finalizar la sesión
    const [sp] = await conn.query('CALL sp_session_end(?)', [session_id]);
    const affected =
      sp?.[0]?.[0]?.affected_rows ?? sp?.[0]?.affected_rows ?? 0;

    // 2. Respuesta exitosa o no según el resultado
    return res.status(200).json({ closed: affected === 1 });
  } catch (err) {
    console.error('SESSION_END_ERROR', err);
    return res.status(500).json({ error: 'Error interno' });
  } finally {
    conn.release();
  }
};
