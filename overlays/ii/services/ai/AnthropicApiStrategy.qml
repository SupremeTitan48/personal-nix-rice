import QtQuick

ApiStrategy {
    function buildEndpoint(model: AiModel): string {
        return model.endpoint;
    }

    function buildRequestData(model: AiModel, messages, systemPrompt: string, temperature: real, tools: list, filePath: string) {
        return {
            "model": model.model,
            "system": systemPrompt,
            "messages": messages.map(message => {
                return {
                    "role": message.role,
                    "content": message.rawContent,
                }
            }),
            "stream": true,
            "temperature": temperature,
            "max_tokens": model.extraParams?.max_tokens ?? 4096,
        };
    }

    function buildAuthorizationHeader(apiKeyEnvVarName: string): string {
        return `-H "x-api-key: \$\{${apiKeyEnvVarName}\}" -H "anthropic-version: 2023-06-01"`;
    }

    function parseResponseLine(line, message) {
        let cleanData = line.trim();
        if (!cleanData || cleanData.startsWith("event:") || cleanData.startsWith(":")) return {};
        if (cleanData.startsWith("data:")) cleanData = cleanData.slice(5).trim();
        if (!cleanData) return {};

        try {
            const dataJson = JSON.parse(cleanData);

            if (dataJson.type === "error") {
                const errorMsg = `**Error**: ${dataJson.error?.message || JSON.stringify(dataJson.error)}`;
                message.rawContent += errorMsg;
                message.content += errorMsg;
                return { finished: true };
            }

            if (dataJson.type === "content_block_delta") {
                const newContent = dataJson.delta?.text ?? "";
                message.rawContent += newContent;
                message.content += newContent;
            }

            if (dataJson.type === "message_delta" && dataJson.usage) {
                return {
                    tokenUsage: {
                        input: dataJson.usage.input_tokens ?? -1,
                        output: dataJson.usage.output_tokens ?? -1,
                        total: -1,
                    }
                };
            }

            if (dataJson.type === "message_stop") return { finished: true };
        } catch (e) {
            console.log("[AI] Anthropic: Could not parse line: ", e);
            message.rawContent += line;
            message.content += line;
        }

        return {};
    }

    function onRequestFinished(message) {
        return {};
    }
}
