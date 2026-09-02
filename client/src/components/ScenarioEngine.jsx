import { useMemo, useState } from 'react';

const STAGES = [
  'STANDARD_PRECAUTIONS', 'PATIENT_ARRIVAL', 'PATIENT_INFORMATION', 'INTERVIEW',
  'VITAL_SIGNS', 'ASSESSMENT', 'ESI_DECISION', 'PATIENT_ROUTING', 'FEEDBACK',
];

/**
 * Shared, data-driven scenario shell.
 * Clinical rules/content are supplied by the API; this component must not classify ESI itself.
 */
export default function ScenarioEngine({ scenario, renderStage }) {
  const [stageIndex, setStageIndex] = useState(0);
  const stage = useMemo(() => STAGES[stageIndex], [stageIndex]);

  const next = () => setStageIndex((current) => Math.min(current + 1, STAGES.length - 1));
  return renderStage({
    scenario,
    stage,
    stageIndex,
    stages: STAGES,
    next,
    isFirstStage: stageIndex === 0,
    isFinalStage: stageIndex === STAGES.length - 1,
  });
}
