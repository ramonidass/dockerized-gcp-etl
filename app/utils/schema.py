from pydantic import BaseModel, field_validator, ValidationInfo
from typing import List, Literal, Optional
from datetime import date


class Visit(BaseModel):
    task_id: str
    node_id: str
    visit_id: int
    visit_date: Optional[date] = None
    original_reported_date: date
    node_age: int
    node_type: str
    task_type: str
    engineer_skill_level: int
    engineer_note: List[int]
    outcome: Literal["SUCCESS", "FAIL"]

    @field_validator("visit_id", "node_age")
    @classmethod
    def non_negative_int(cls, v: int, info: ValidationInfo) -> int:
        if v < 0:
            raise ValueError(f"{info.field_name} must be non-negative")
        return v

    @field_validator("engineer_skill_level", mode="before")
    @classmethod
    def non_negative_skill(cls, v: int | str) -> int:
        if isinstance(v, str):
            v = int(v.replace("LEVEL", ""))
        if v < 0:
            raise ValueError("engineer_skill_level must be non-negative")
        return v

    @field_validator("engineer_note", mode="before")
    @classmethod
    def split_notes(cls, v: str | List[int]) -> List[int]:
        if isinstance(v, str):
            return [int(i) for i in v.split()]
        return v
