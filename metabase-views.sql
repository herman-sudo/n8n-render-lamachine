-- Vues SQL pour Metabase - Analyse des agents IA, requêtes et tokens

-- Vue 1: Statistiques des agents IA
CREATE OR REPLACE VIEW agent_stats AS
SELECT 
    a.id as agent_id,
    a.name as agent_name,
    a.icon as agent_icon,
    COUNT(cm.id) as total_messages,
    COUNT(CASE WHEN cm.created_at >= NOW() - INTERVAL '24 hours' THEN 1 END) as messages_24h,
    COUNT(CASE WHEN cm.created_at >= NOW() - INTERVAL '7 days' THEN 1 END) as messages_7d,
    MAX(cm.created_at) as last_activity
FROM agents a
LEFT JOIN chat_hub_messages cm ON a.id = cm.agent_id
GROUP BY a.id, a.name, a.icon
ORDER BY total_messages DESC;

-- Vue 2: Consommation de tokens par agent
CREATE OR REPLACE VIEW agent_token_usage AS
SELECT 
    a.id as agent_id,
    a.name as agent_name,
    DATE(cm.created_at) as date,
    COUNT(*) as message_count,
    -- Estimation basée sur la longueur des messages (à adapter selon votre structure)
    SUM(LENGTH(cm.content)) as total_characters,
    SUM(LENGTH(cm.content)) / 4 as estimated_tokens -- ~4 caractères = 1 token
FROM agents a
JOIN chat_hub_messages cm ON a.id = cm.agent_id
WHERE cm.created_at >= NOW() - INTERVAL '30 days'
GROUP BY a.id, a.name, DATE(cm.created_at)
ORDER BY date DESC, estimated_tokens DESC;

-- Vue 3: Requêtes par workflow et agent
CREATE OR REPLACE VIEW workflow_agent_queries AS
SELECT 
    w.name as workflow_name,
    w.id as workflow_id,
    a.name as agent_name,
    a.id as agent_id,
    COUNT(e.id) as execution_count,
    AVG(EXTRACT(EPOCH FROM (e.finished_at - e.started_at))) as avg_execution_time_seconds,
    MAX(e.finished_at) as last_execution,
    COUNT(CASE WHEN e.mode = 'manual' THEN 1 END) as manual_executions,
    COUNT(CASE WHEN e.mode = 'trigger' THEN 1 END) as trigger_executions
FROM workflows w
LEFT JOIN agents a ON w.id = a.workflow_id -- Adapter selon votre schéma
LEFT JOIN execution_entity e ON w.id = e.workflow_id
WHERE e.started_at >= NOW() - INTERVAL '30 days'
GROUP BY w.id, w.name, a.id, a.name
ORDER BY execution_count DESC;

-- Vue 4: Activité journalière des agents
CREATE OR REPLACE VIEW daily_agent_activity AS
SELECT 
    DATE(cm.created_at) as date,
    a.name as agent_name,
    COUNT(*) as messages_sent,
    COUNT(DISTINCT DATE(cm.created_at)) as active_days,
    AVG(LENGTH(cm.content)) as avg_message_length
FROM agents a
JOIN chat_hub_messages cm ON a.id = cm.agent_id
WHERE cm.created_at >= NOW() - INTERVAL '90 days'
GROUP BY DATE(cm.created_at), a.name
ORDER BY date DESC, messages_sent DESC;

-- Vue 5: Performance des agents IA
CREATE OR REPLACE VIEW agent_performance_metrics AS
SELECT 
    a.id as agent_id,
    a.name as agent_name,
    COUNT(cm.id) as total_interactions,
    AVG(LENGTH(cm.content)) as avg_response_length,
    COUNT(CASE WHEN cm.created_at >= NOW() - INTERVAL '1 hour' THEN 1 END) as interactions_last_hour,
    COUNT(CASE WHEN cm.created_at >= NOW() - INTERVAL '24 hours' THEN 1 END) as interactions_last_24h,
    EXTRACT(EPOCH FROM (MAX(cm.created_at) - MIN(cm.created_at))) / 3600 as hours_active_span
FROM agents a
LEFT JOIN chat_hub_messages cm ON a.id = cm.agent_id
GROUP BY a.id, a.name
HAVING COUNT(cm.id) > 0
ORDER BY total_interactions DESC;

-- Vue 6: Utilisation des credentials par agent
CREATE OR REPLACE VIEW agent_credentials_usage AS
SELECT 
    a.name as agent_name,
    c.name as credential_name,
    c.type as credential_type,
    COUNT(w.id) as workflows_using,
    MAX(w.updated_at) as last_used
FROM agents a
JOIN workflows w ON a.id = w.agent_id -- Adapter selon votre schéma
JOIN workflow_credentials wc ON w.id = wc.workflow_id
JOIN credentials c ON wc.credentials_id = c.id
GROUP BY a.name, c.name, c.type
ORDER BY workflows_using DESC;

-- Vue 7: Tendances d'utilisation des tokens
CREATE OR REPLACE VIEW token_trends AS
SELECT 
    DATE_TRUNC('week', cm.created_at) as week,
    a.name as agent_name,
    COUNT(*) as message_count,
    SUM(LENGTH(cm.content)) / 4 as estimated_tokens,
    LAG(SUM(LENGTH(cm.content)) / 4) OVER (PARTITION BY a.name ORDER BY DATE_TRUNC('week', cm.created_at)) as previous_week_tokens,
    ((SUM(LENGTH(cm.content)) / 4) - LAG(SUM(LENGTH(cm.content)) / 4) OVER (PARTITION BY a.name ORDER BY DATE_TRUNC('week', cm.created_at))) / 
    NULLIF(LAG(SUM(LENGTH(cm.content)) / 4) OVER (PARTITION BY a.name ORDER BY DATE_TRUNC('week', cm.created_at)), 0) * 100 as token_growth_percentage
FROM agents a
JOIN chat_hub_messages cm ON a.id = cm.agent_id
WHERE cm.created_at >= NOW() - INTERVAL '12 weeks'
GROUP BY DATE_TRUNC('week', cm.created_at), a.name
ORDER BY week DESC, estimated_tokens DESC;
